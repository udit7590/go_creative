class Comment < ActiveRecord::Base

  belongs_to :project
  belongs_to :user
  # Has been abused by many
  has_many :abused_comments, as: :abusable, class_name: 'Abuse'

  # -------------- SECTION FOR VALIDATIONS ----------------------
  # -------------------------------------------------------------
  validates :description, presence: true, length: { maximum: 10000 }

  # -------------- SECTION FOR SCOPES ---------------
  # -------------------------------------------------------------
  #FIXME_AB: Please check with sahil if we can use act_as_paranoid for soft deletion
  scope :deleted, -> (is_deleted) { where(deleted: is_deleted) }
  scope :safe, -> { where(spam: false).deleted(false) }
  scope :visible_to_all, -> (visibility) { where(visible_to_all: visibility).deleted(false) }
  scope :order_by_date, -> (page = 1) { order(:created_at).limit(Constants::INITIAL_COMMENT_DISPLAY_LIMIT).offset((page - 1) * Constants::INITIAL_COMMENT_DISPLAY_LIMIT) }
  scope :latest, -> (page = 1) { order_by_date.deleted(false).limit(Constants::INITIAL_COMMENT_DISPLAY_LIMIT).offset((page - 1) * Constants::INITIAL_COMMENT_DISPLAY_LIMIT) }

  # -------------- SECTION FOR METHODS ---------------
  # -------------------------------------------------------------

  def mark_deleted(user)
    return false unless user
    update(deleted: true, deleted_at: DateTime.current, deleted_by: user.id)
  end

  def abuse(user)
    abused_comment      = abused_comments.build
    abused_comment.user = user
    abused_comment.save
  end

  def already_abused_by?(user)
    user && abused_comments.where(user_id: user.id).size > 0
  end

  # Only if user is comment owner or project owner
  def can_be_deleted_by?(user)
    return false unless user
    user.id == user_id || user.id == project.user_id
  end
  
end
