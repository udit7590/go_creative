class Contribution < ActiveRecord::Base
  include AASM
  
  # -------------- SECTION FOR ASSOCIATIONS ---------------------
  # -------------------------------------------------------------
  belongs_to :user
  belongs_to :project

  # -------------- SECTION FOR STATE MACHINE --------------------
  # -------------------------------------------------------------
  aasm column: 'state'.freeze do
    state :contributed, initial: true
    state :payment_initiated
    state :accepted
    state :rejected

    event :initiate_payment do
      transitions from: :contributed, to: :payment_initiated
    end

    event :accept do
      transitions from: :payment_initiated, to: :accepted
    end

    event :reject do
      transitions from: :payment_initiated, to: :rejected
    end
  end

  # -------------- SECTION FOR CALLBACKS  -----------------------
  # -------------------------------------------------------------

  after_save :update_total_contribution_cache
  after_destroy :remove_contribution_amount_from_cache

  # -------------- SECTION FOR SCOPES AND METHODS ---------------
  # -------------------------------------------------------------
  scope :volunteered, -> { where(state: 'contributed') }

  def update_total_contribution_cache
    if project && project.collected_amount
      # To make sure that if if the cache is updated for first time, it is in valid state. (Useful for older data)
      if project.collected_amount == 0
        # TODO: The contribution amount to be updated will also depend upon state of contribution
        collected_amount = project.contributions.sum(:amount)
        contributors_count = project.contributions.length
      # If amount is updated, changed amount is added/subtracted
      elsif changed?
        collected_amount = project.collected_amount + self.amount - changed_attributes[:amount]
      # New Contributions are added to cache column
      else
        collected_amount = project.collected_amount + self.amount
        contributors_count = project.contributors_count + 1
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

end
