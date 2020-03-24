class CommentsController < ApplicationController
  
  # This controller currently handles ajax requests and so rejects all other requests
  before_action :check_ajax_request

  before_action :authenticate_user!

  # Loads project on which comment has to be made
  before_action :load_project, only: [:new, :load_more]

  # Load the user who is making the comment.
  # FUTURE: Make sure user has rights to comment on that project
  before_action :load_user, only: [:new, :report_abuse]

  # Builds the comment based on whether the commenter is admin, project owner or 
  # some other registered user or maybe a contributor to that project
  before_action :build_comment, only: :new

  # Load the comment from the id which the user/admin want to delete or report abuse
  before_action :load_comment, only: [:delete, :undo_delete, :report_abuse, :destroy]

  # Only project owner has the right to soft delete a comment
  before_action :verify_comment_author, only: [:delete, :undo_delete]

  # Check that the comment has not already been abused by the same user
  before_action :check_not_already_abused, only: :report_abuse

  # JSON REQUEST
  def new
    if(@comment.save)
      render :add_comment
    else
      render json: { error: true, description: @comment.errors.full_messages }
    end
  end

  # JSON REQUEST
  def load_more
    if @project.owner?(current_user)
      @comments = @project.comments.order_by_date(params[:page].to_i)
    else
      @comments = @project.comments.latest(params[:page].to_i).visible_to_all(true)
    end
    @is_more_available = @comments.length == Constants::INITIAL_COMMENT_DISPLAY_LIMIT
    render :load
  end

  # JS REQUEST
  def delete
    if @comment.mark_deleted(current_user)
      render 'delete', locals: { deleted: true }
    else
      render js: 'alert("Sorry. We are unable to delete your comment.")'
    end
  end

  # JS REQUEST
  def undo_delete
    if(@comment.update(deleted: false, deleted_at: DateTime.current, deleted_by: current_user.id))
      render 'delete', locals: { deleted: false }
    else
      render js: 'alert("Sorry. We are unable to undo your deleted comment.")'
    end
  end

  # JS REQUEST
  def report_abuse
    if(@comment.abuse(@user))
      render 'abused', locals: { abused: true }
    else
      render js: 'alert("Sorry. We are unable to perform this action.")'
    end
  end

  protected

    # ---------------------------------------------------------------------------------
    # SECTION FOR FILTERS
    # ---------------------------------------------------------------------------------

    def check_ajax_request
      redirect_to controller: :home unless request.xhr?
    end

    def load_user
      @user = User.find_by(id: params[:user_id])
      unless @user
        render js: "alert(#{ (I18n.t :no_user, scope: [:comments, :views]) })"
      end
    end

    def load_project
      @project = Project.find_by(id: params[:project_id])
      unless @project
        render json: { error: true, description: (I18n.t :no_project, scope: [:comments, :views]) }
      end
    end

    def load_comment
      @comment = Comment.find_by(id: (params[:comment_id] || params[:id]))
      unless @comment
        render js: "alert(#{ (I18n.t :no_comment, scope: [:comments, :views]) })"
      end
    end

    def build_comment
      # PROJECT OWNER is making comment
      if @project.owner?(current_user) && !@project.published?
        @comment = @project.comments.build(visible_to_all: false, spam: false)
        @comment.user_id = @user.id
      # REGISTERED USER is making comment
      else
        @comment = @project.comments.build(visible_to_all: true, spam: false)
        @comment.user_id = @user.id
      end
      
      @comment.description = params[:data][:comment][:description]
    end

    def verify_comment_author
      unless @comment.can_be_deleted_by?(current_user)
        render js: "alert(#{ (I18n.t :only_comment_author_or_project_owner_delete, scope: [:comments, :views]) })"
      end
    end

    def check_not_already_abused
      if @comment.already_abused_by?(current_user)
        render :abused, locals: { abused: false, error: true, description: :already_abused }
      end
    end

end
