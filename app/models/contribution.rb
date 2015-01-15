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

  # -------------- SECTION FOR SCOPES AND METHODS ---------------
  # -------------------------------------------------------------
  scope :volunteered, -> { where(state: 'contributed') }
  
end