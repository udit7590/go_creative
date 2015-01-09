class Comment < ActiveRecord::Base

  #FIXME_AB: following constant should not be in model should be application level comment
  INITIAL_COMMENT_DISPLAY_LIMIT = 20

  belongs_to :project
  belongs_to :user
  has_many :abused_comments, as: :abusable, class_name: 'Abuse'

  # -------------- SECTION FOR VALIDATIONS ----------------------
  # -------------------------------------------------------------
  validates :description, presence: true

  # -------------- SECTION FOR SCOPES AND METHODS ---------------
  # -------------------------------------------------------------
  #FIXME_AB: Please check with sahil sir if we can use act_as_paranoid for soft deletion
  scope :deleted, -> (is_deleted) { where(deleted: is_deleted) }
  scope :safe, -> { where(spam: false).deleted(false) }
  scope :visible_to_all, -> (visibility) { where(visible_to_all: visibility).deleted(false) }
  scope :order_by_date, -> (page = 1) { order(created_at: :desc).limit(INITIAL_COMMENT_DISPLAY_LIMIT).offset((page - 1) * INITIAL_COMMENT_DISPLAY_LIMIT) }
  scope :latest, -> (page = 1) { order_by_date.deleted(false).limit(INITIAL_COMMENT_DISPLAY_LIMIT).offset((page - 1) * INITIAL_COMMENT_DISPLAY_LIMIT) }
  
end
