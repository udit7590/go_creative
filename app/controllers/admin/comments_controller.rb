class Admin::CommentsController < ::ApplicationController
  
  # This controller currently handles ajax requests and so rejects all other requests
  before_action :check_ajax_request

  before_action :authenticate_admin_user!

  # Loads project on which comment has to be made
  before_action :load_project, only: [:new, :load_more]

  # Load the user who is making the comment.
  # FUTURE: Make sure user has rights to comment on that project
  before_action :load_user, only: :new

  # Builds the comment based on whether the commenter is admin
  before_action :build_comment, only: :new

  # Load the comment from the id which the admin want to delete or report abuse
  before_action :load_comment, only: :destroy

  # Only admin can completely remove the comment from database
  before_action :check_admin, only: :destroy

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
    if(params[:admin] == 'true')
      @admin = true
      @comments = @project.comments.order_by_date(params[:page].to_i)
    end
    @is_more_available = @comments.length == Constants::INITIAL_COMMENT_DISPLAY_LIMIT
    render :load
  end

  # JS REQUEST
  def destroy
    if(@comment.destroy)
      render 'delete', locals: { deleted: true }
    else
      render js: 'alert("Sorry. We are unable to delete this comment.")'
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
      if params[:data] && params[:data][:admin]
        @admin = AdminUser.find_by(id: params[:data][:admin_user_id])
        unless @admin
          render json: { error: true, description: (I18n.t :no_admin, scope: [:comments, :views]) }
        end
      end
    end

    def load_project
      @project = Project.find_by(id: params[:project_id])
      unless @project
        render json: { error: true, description: (I18n.t :no_project, scope: [:comments, :views]) }
      end
    end

    def check_admin
      @admin = current_admin_user
      unless @admin
        render js: "alert(#{ (I18n.t :no_admin, scope: [:comments, :views]) })"
      end
    end

    def load_comment
      @comment = Comment.find_by(id: (params[:comment_id] || params[:id]))
      unless @comment
        render js: "alert(#{ (I18n.t :no_comment, scope: [:comments, :views]) })"
      end
    end

    def build_comment
      if params[:data][:admin]
        @comment = @project.comments.build(visible_to_all: false, spam: false)
        @comment.admin_user_id = @admin.id
        @admin = true
      end
      
      @comment.description = params[:data][:comment][:description]
    end

    def check_admin
      @admin = current_admin_user
      unless @admin
        render js: 'alert("Sorry. No admin user is currently logged in.")'
      end
    end

end
