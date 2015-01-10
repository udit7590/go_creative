require 'rails_helper'
require 'support/shared_projects_controller_spec'

RSpec.describe ProjectsController, type: :controller do

  describe '#index' do
    let(:projects) { 3.times { FactoryGirl.create(:published_investment_project) } }

    it_behaves_like 'display published projects' do
      let(:action_name) { :index }
    end
  end

  describe '#charity_projects' do
    it_behaves_like 'display published projects' do
      let(:action_name) { :charity_projects }
    end
  end

  describe '#investment_projects' do
    it_behaves_like 'display published projects' do
      let(:action_name) { :investment_projects }
    end
  end

  describe '#load_more_projects' do
    def load_more
      get :load_more_projects, for_action: 'charity_projects', format: :json, page: 1
    end

    context 'when the user is not logged in' do
      it 'should return success page' do
        load_more
        expect(response).to have_http_status(:success) # 200
      end
      it 'should load more published projects' do
        load_more
        expect(response).to render_template(:load)
      end
    end

    context 'when the user is logged in' do
      login_user

      it 'should return success page' do
      load_more
        expect(response).to have_http_status(:success) # 200
      end
      it 'should load more published projects' do
        load_more
        expect(response).to render_template(:load)
      end
    end
  end

  describe '#user_projects' do
    def user_projects
      get :user_projects
    end

    context 'when the user is not logged in' do
      it_behaves_like 'not logged in' do
        let(:action) { user_projects }
      end
    end

    context 'when the user is logged in' do
      login_user

      it 'should return success page' do
        user_projects
        expect(response).to have_http_status(:success) # 200
      end
      it 'should show user projects' do
        user_projects
        expect(response).to render_template(:user_projects)
      end
    end
  end

  describe '#new' do
    def do_new
      get :new
    end

    context 'when the user is not logged in' do
      it_behaves_like 'not logged in' do
        let(:action) { do_new }
      end
    end

    context 'when the user is logged in' do
      login_user
      context 'when user sends a request to create new project' do
        it_behaves_like 'logged in' do
          let(:action) { do_new }
          let(:status) { :success }
          let(:render_or_redirect) { render_template(:new) }
        end
      end
    end
  end

  describe '#create' do
    let(:project_attributes) { FactoryGirl.attributes_for(:created_charity_project) }

    def do_create
      post :create, project: project_attributes
    end

    context 'when the user is not logged in' do
      it_behaves_like 'not logged in' do
        let(:action) { do_create }
      end
    end

    context 'when the user is logged in' do
      login_user
      context 'when user sends data to create new project(user details incomplete)' do
        context 'when valid attributes' do
          it_behaves_like 'logged in' do
            let(:action) { do_create }
            let(:status) { 302 }
            let(:render_or_redirect) { redirect_to(controller: :accounts, action: :update_pan_details) }
          end
          it 'should create a new project' do
            expect(->{ do_create }).to change(Project, :count).by(1)
          end
        end
        context 'when invalid attributes' do
          let(:project_attributes) { { title: '' } }

          it_behaves_like 'logged in' do
            let(:action) { do_create }
            let(:status) { 400 }
            let(:render_or_redirect) { render_template(:new) }
          end
          it 'should not create a new project' do
            expect(->{ do_create }).to change(Project, :count).by(0)
          end
        end
      end
    end
  end

  describe '#edit' do

    def do_edit
      get :edit, id: 2020
    end

    context 'when the user is not logged in' do
      it_behaves_like 'not logged in' do
        let(:action) { do_edit }
      end
    end

    # context 'when the user is logged in' do
    #   login_user
    #   context 'when user sends a request to edit project' do
    #     it_behaves_like 'logged in' do
    #       let(:action) { do_edit }
    #       let(:status) { 302 }
    #       let(:render_or_redirect) { redirect_to(project_path(method: :patch)) }
    #     end
    #   end
    # end

  end

  describe '#update' do
    let(:project_attributes) { FactoryGirl.attributes_for(:published_charity_project) }

    def do_update
      patch :update, project: project_attributes
    end

    # context 'when the user is not logged in' do
    #   it_behaves_like 'not logged in' do
    #     let(:action) { do_update }
    #   end
    # end

    # context 'when the user is logged in' do
    #   login_user
    #   context 'when user sends data to update project' do
    #     context 'when valid attributes' do
    #       it_behaves_like 'logged in' do
    #         let(:action) { do_update }
    #         let(:status) { 302 }
    #         let(:render_or_redirect) { redirect_to(:show) }
    #       end
    #       it 'should update the project' do
    #         expect(->{ do_update }).to change(Project, :updated_at)
    #       end
    #     end
    #     context 'when invalid attributes' do
    #       let(:project_attributes) { { title: '' } }

    #       it_behaves_like 'logged in' do
    #         let(:action) { do_update }
    #         let(:status) { 400 }
    #         let(:render_or_redirect) { render_template(:new) }
    #       end
    #     end
    #   end
    # end

  end

end
