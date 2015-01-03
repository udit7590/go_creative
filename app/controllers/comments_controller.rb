class CommentsController < ApplicationController
  
  before_action :check_ajax_request
  before_action :load_user_and_project, only: :new
  before_action :load_project, only: :load_more
  before_action :verify_comment_author, only: [:delete, :undo_delete]
  before_action :load_comment, only: :report_abuse
  before_action :check_not_already_abused, only: :report_abuse

  def new
    @comment = @project.comments.build(visible_to_all: true, spam: false)
    @comment.description = params[:data][:comment][:description]
    @comment.user_id = @user.id

    if(@comment.save)
      render 'add_comment'
    else
      render json: '{ error: true }'
    end
  end

  def load_more
    @comments = @project.comments.latest(params[:page].to_i)
    @is_more_available = @comments.length == Comment::INITIAL_COMMENT_DISPLAY_LIMIT
    render 'load'
  end

  def delete
    if(@comment.update(deleted: true, deleted_at: DateTime.current, deleted_by: current_user.id))
      render 'delete', locals: { deleted: true }
    else
      render js: 'alert("Sorry. We are unable to delete your comment.")'
    end
  end

  def undo_delete
    if(@comment.update(deleted: false, deleted_at: DateTime.current, deleted_by: current_user.id))
      render 'delete', locals: { deleted: false }
    else
      render js: 'alert("Sorry. We are unable to undo your deleted comment.")'
    end
  end

  def report_abuse
    @abused_comment = @comment.abused_comments.build
    @abused_comment.user = current_user
    if(@abused_comment.save)
      render 'abused', locals: { abused: true }
    else
      render js: 'alert("Sorry. We are unable to perform this action.")'
    end
  end

  protected

    def check_ajax_request
      redirect_to controller: :home unless request.xhr?
    end

    def load_user_and_project
      load_project

      @user = User.find_by_id(params[:data][:user_id])
      unless @user
        #TODO: RETURN ERROR JSON
      end
    end

    def load_project
      @project = Project.find_by_id(params[:project_id])
      unless @project
        #TODO: RETURN ERROR JSON
      end
    end

    def verify_comment_author
      load_comment

      # TODO DISCUSS: comment.project.user.id
      if current_user.id != @comment.user.id && current_user.id != @comment.project.user.id
        render js: 'alert("Sorry. Only project owner or comment author can delete the comment.")'
      end
    end

    def load_comment
      @comment = Comment.find_by_id(params[:comment_id])
      unless @comment
        render js: 'alert("Cannot find any such comment.")'
      end
    end

    def check_not_already_abused
      already_abused_by = @comment.abused_comments.pluck(:user_id)
      if already_abused_by.include? current_user.id
        render 'abused', locals: { abused: false, error: true, description: :already_abused }
      end
    end

end
