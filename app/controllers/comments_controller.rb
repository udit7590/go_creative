class CommentsController < ApplicationController
  
  before_action :check_ajax_request
  before_action :check_admin, only: :destroy
  before_action :load_project, only: [:load_more, :new]
  before_action :load_user, only: [:new, :report_abuse]
  before_action :build_comment, only: :new
  before_action :verify_comment_author, only: [:delete, :undo_delete]
  before_action :load_comment, only: [:report_abuse, :destroy]
  before_action :check_not_already_abused, only: :report_abuse

  def new
    if(@comment.save)
      #FIXME_AB: Prefer symbols over strings and save memory
      render 'add_comment'
    else
      render json: { error: true }
    end
  end

  def load_more
    #FIXME_AB: Lets try to find out a way to reduce complexity 
    if(params[:admin] == 'true')
      @admin = true
      @comments = @project.comments.order_by_date(params[:page].to_i)
    else
      #FIXME_AB: project.owner?(current_user) or project.creator?(current_user)
      if @project.user == current_user
        @comments = @project.comments.order_by_date(params[:page].to_i)
      else
        @comments = @project.comments.latest(params[:page].to_i).visible_to_all(true)
      end
    end
    @is_more_available = @comments.length == Comment::INITIAL_COMMENT_DISPLAY_LIMIT
    render 'load'
  end

  def delete
    #FIXME_AB: you should have something like comment.mark_deleted(current_user). basically move it to model
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
    #FIXME_AB: simply comment.mark_abuse!
    @abused_comment = @comment.abused_comments.build
    @abused_comment.user = current_user
    if(@abused_comment.save)
      render 'abused', locals: { abused: true }
    else
      render js: 'alert("Sorry. We are unable to perform this action.")'
    end
  end

  def destroy
    #FIXME_AB: Why not comment.destroy ?
    if(@comment.delete)
      render 'delete', locals: { deleted: true }
    else
      render js: 'alert("Sorry. We are unable to delete this comment.")'
    end
  end

  protected

    def check_ajax_request
      redirect_to controller: :home unless request.xhr?
    end

    def load_user
      #FIXME_AB: don't mix admin control with user.
      if params[:data] && params[:data][:admin]
        @admin = AdminUser.find_by(id: params[:data][:admin_user_id])
        unless @admin
          render json: { error: true, description: 'Cannot find any admin user.' }
        end
      else
        @user = User.find_by(id: params[:user_id])
        unless @user
          render js: 'alert("Only registered users can report abuse a comment.")'
        end
      end
    end

    def load_project
      @project = Project.find_by(id: params[:project_id])
      unless @project
        render json: { error: true, description: 'Cannot find any such project.' }
      end
    end

    def build_comment
      #FIXME_AB: Keep admin and user sections separate 
      if params[:data][:admin]
        #FIXME_AB: I guess spam: false should be a default scope
        @comment = @project.comments.build(visible_to_all: false, spam: false)
        @comment.admin_user_id = @admin.id
        @admin = true
      elsif @project.user == current_user && !@project.published?
        @comment = @project.comments.build(visible_to_all: false, spam: false)
        @comment.user_id = @user.id
      else
        @comment = @project.comments.build(visible_to_all: true, spam: false)
        @comment.user_id = @user.id
      end
      
      @comment.description = params[:data][:comment][:description]
    end

    def verify_comment_author
      load_comment

      # TODO DISCUSS: comment.project.user.id
      #FIXME_AB: When you have bigger conditions move them out in a method. comment.can_be_deleted_by?(current_user)
      if current_user.id != @comment.user.id && current_user.id != @comment.project.user.id
        render js: 'alertlocals("Sorry. Only project owner or comment author can delete the comment.")'
      end
    end

    def check_admin
      @admin = current_admin_user
      unless @admin
        render js: 'alert("Sorry. No admin user is currently logged in.")'
      end
    end

    def load_comment
    #FIXME_AB: simpilify it by taking id in a local variable so that you have Comment.find_by only once
      @comment = Comment.find_by(id: params[:comment_id] || Comment.find_by(id: params[:id]))
      unless @comment
        render js: 'alert("Cannot find any such comment.")'
      end
    end

    def check_not_already_abused
      #FIXME_AB: instead of > 0 use exists?
      if current_user && @comment.abused_comments.where(user_id: current_user.id).size > 0
        render 'abused', locals: { abused: false, error: true, description: :already_abused }
      end
    end

end
