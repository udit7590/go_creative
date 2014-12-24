class Project < ActiveRecord::Base

  attr_accessor :project_type, :minimum_amount_per_contribution

  # -------------- SECTION FOR ASSOCIATIONS ---------------------
  # -------------------------------------------------------------
  has_many :images, -> { where document: false }, as: :imageable
  has_many :legal_documents, -> { where document: true }, as: :imageable, class_name: 'Image'
  belongs_to :user

  accepts_nested_attributes_for :images, :legal_documents
  
  # -------------- SECTION FOR VALIDATIONS ----------------------
  # -------------------------------------------------------------
  validates :type, presence: true
  validates :end_date, presence: true, date: { greater_than_or_equal_to: (5.days.from_now.beginning_of_day) }
  validates :title, uniqueness: true
  validates :amount_required, numericality: { only_integer: true, greater_than: 0, less_than: 10000000 }

  validate :amount_multiple_of_100

  # -------------- SECTION FOR SCOPES AND METHODS ---------------
  # -------------------------------------------------------------
  scope :charity, -> { where(type: 'CharityProject') }
  scope :investment, -> { where(type: 'InvestmentProject') }

  # To determine which all projects we can make
  def self.types
    %w(CharityProject InvestmentProject)
  end

  def amount_multiple_of_100
    errors[:amount_required] << 'should be a multiple of 100' if (!(amount_required % 100).is_a? Fixnum)
  end

end
