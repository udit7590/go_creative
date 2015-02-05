class Contribution < ActiveRecord::Base
  include AASM
  
  attr_accessor :card_number, :card_verification
  attr_reader :current_transaction

  # -------------- SECTION FOR ASSOCIATIONS ---------------------
  # -------------------------------------------------------------
  belongs_to :user
  belongs_to :project
  has_many :transactions, class_name: 'ContributionTransaction'

  # -------------- SECTION FOR STATE MACHINE --------------------
  # -------------------------------------------------------------
  aasm column: 'state'.freeze do
    state :contributed, initial: true
    state :payment_initiated
    state :accepted
    state :rejected
    state :payment_error_occurred
    state :refunded

    event :initiate_payment do
      transitions from: :contributed, to: :payment_initiated
    end

    event :accept do
      transitions from: :payment_initiated, to: :accepted
    end

    event :reject do
      transitions from: :payment_initiated, to: :rejected
    end

    event :payment_error do
      transitions from: :payment_initiated, to: :payment_error_occurred
    end

    event :refund, before: :refund_amount do
      transitions from: :accepted, to: :refunded
    end

  end

  # -------------- SECTION FOR VALIDATIONS  ---------------------
  # -------------------------------------------------------------

  #Complete the project if amount received
  after_save :complete_project, if: :amount_fully_funded?
  # after_destroy :remove_contribution_amount_from_cache

  # validate :validate_card

  # -------------- SECTION FOR SCOPES AND METHODS ---------------
  # -------------------------------------------------------------
  scope :volunteered, -> { where(state: 'contributed') }
  scope :accepted, -> { where(state: 'accepted') }
  scope :order_by_creation, -> { order(:created_at) }

  def create_customer!(token)
    raise 'Invalid arguments for creating customer' unless (token || user)
    customer = Stripe::Customer.create(
      card: token,
      description: user.email
    )
    if customer
      update(stripe_customer_id: customer.id)
    end
    raise 'Invalid token' unless (customer || stripe_customer_id)
  end

  def charge_customer!
    Stripe::Charge.create(
      amount: amount_in_paisa, # in paisa
      currency: 'inr',
      customer: stripe_customer_id
    )
  end

  def amount_in_paisa
    amount.to_i * 100
  end

  def purchase(token)
    Contribution.transaction do
      create_customer!(token)
      response = charge_customer!
      @current_transaction = transactions.create!(action: 'Purchase', amount: amount, response: response)
      initiate_payment!
      if response.captured
        update_total_contribution_cache
        accept!        
      else
        payment_error!
      end
      response.captured
    end
  end

  def price_in_cents
    self.amount
  end

  private
    def update_total_contribution_cache
      #FIXME_AB: Please try to remove nested if-else 
      if project && project.collected_amount
        # To make sure that if if the cache is updated for first time, it is in valid state. (Useful for older data)
        if project.collected_amount == 0
          # TODO: The contribution amount to be updated will also depend upon state of contribution
          collected_amount = project.contributions.sum(:amount)
          contributors_count = project.contributions.length
        # If amount is updated, changed amount is added/subtracted
        elsif changed?
          collected_amount = project.collected_amount + self.amount - changed_attributes[:amount].to_i
        # New Contributions are added to cache column
        else
          collected_amount = project.collected_amount + self.amount
          contributors_count = project.contributors_count.to_i + 1
        end
      end
      project.update(collected_amount: collected_amount, contributors_count: contributors_count)
    end

    def remove_contribution_amount_from_cache
      if project && project.collected_amount && project.collected_amount > 0
        collected_amount = project.collected_amount - self.amount
        contributors_count = project.contributors_count - 1
        project.update(collected_amount: collected_amount, contributors_count: contributors_count)
      end
    end

    def validate_card
      unless credit_card.valid?
        credit_card.errors.full_messages.each do |message|
          errors[:base] << message
        end
      end
    end

    def credit_card
      @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
        type:               brand,
        number:             card_number,
        verification_value: card_verification,
        month:              card_expires_on.month,
        year:               card_expires_on.year,
        first_name:         user.first_name,
        last_name:          user.last_name
      )
    end

    def check_stripe_customer_id
      !!stripe_customer_id
    end

    def refund_amount
      if stripe_customer_id
        charge_id = transactions.where(action: 'Purchase', success: true).last.authorization
        charge = Stripe::Charge.retrieve(charge_id)
        refunded_amount = charge.refunds.inject(0) {|memo, refund| memo + refund.amount  }
        if amount_in_paisa > refunded_amount
          response = charge.refunds.create
          @current_transaction = transactions.create!(action: 'Refund', amount: amount_in_paisa / 100, response: response)
        else
          # Already Refunded
        end
      end
        
    rescue Stripe::InvalidRequestError => err
      puts "#{err}"
      raise ActiveRecord::Rollback      
    end

    def amount_fully_funded?
      project.amount_collected >= project.amount_required
    end

    def complete_project
      project.complete!
    end

end
