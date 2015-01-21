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

  end

  # -------------- SECTION FOR VALIDATIONS  ---------------------
  # -------------------------------------------------------------

  # after_save :update_total_contribution_cache
  # after_destroy :remove_contribution_amount_from_cache

  validate :validate_card

  # -------------- SECTION FOR SCOPES AND METHODS ---------------
  # -------------------------------------------------------------
  scope :volunteered, -> { where(state: 'contributed') }
  scope :order_by_creation, -> { order(:created_at) }

  def purchase
    response = GATEWAY.purchase(price_in_cents, credit_card, ip: ip_address)
    @current_transaction = transactions.create!(action: 'Purchase', amount: price_in_cents, response: response)
    payment_initiated!
    if response.success?
      update_total_contribution_cache
      accepted!
    else
      payment_error!
    end
    response.success?
  end

  def price_in_cents
    self.amount
  end

  private
    def update_total_contribution_cache
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
        type:               card_type,
        number:             card_number,
        verification_value: card_verification,
        month:              card_expires_on.month,
        year:               card_expires_on.year,
        first_name:         user.first_name,
        last_name:          user.last_name
      )
    end

end
