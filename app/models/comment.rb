class Comment < ActiveRecord::Base

  INITIAL_COMMENT_DISPLAY_LIMIT = 20

  belongs_to :project
  belongs_to :user
  has_many :abused_comments, as: :abusable, class_name: 'Abuse'

  # -------------- SECTION FOR VALIDATIONS ----------------------
  # -------------------------------------------------------------
  validates :description, presence: true

  # -------------- SECTION FOR SCOPES AND METHODS ---------------
  # -------------------------------------------------------------
  scope :deleted, -> (is_deleted) { where(deleted: is_deleted) }
  scope :safe, -> { where(spam: false).deleted(false) }
  scope :visible_to_all, -> (visibility) { where(visible_to_all: visibility).deleted(false) }
  scope :order_by_date, ->  { order(created_at: :desc).deleted(false) }
  scope :latest, -> (page = 1) { order_by_date.limit(INITIAL_COMMENT_DISPLAY_LIMIT).offset((page - 1) * INITIAL_COMMENT_DISPLAY_LIMIT) }
  
end
