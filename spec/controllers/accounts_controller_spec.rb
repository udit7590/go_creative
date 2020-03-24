require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  
  describe '#edit' do

    def do_edit
      get :edit
    end

    context 'when the user is not logged in' do
      it 'should redirect to login page' do
        do_edit
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'if the user is logged in' do
      login_user
      context 'when user sends a request to edit account details' do
        it 'should return success page' do
          do_edit
          expect(response).to have_http_status(:success) # 200
        end
        it 'should render edit page' do
          do_edit
          expect(response).to render_template(:edit)
        end
      end
    end

  end

  describe '#update' do

    def do_update_patch
      patch :update, user: { first_name: 'MARTIN' }
    end

    def do_update_put
      patch :update
    end

    context 'when the user is not logged in' do
      it 'should redirect to login page' do
        do_update_patch
        expect(response).to redirect_to new_user_session_path
      end
      it 'should redirect to login page' do
        do_update_put
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'if the user is logged in' do
      login_user
      context 'when user sends a request to update account details' do
        it 'should return success page' do
          do_update_patch
          expect(response).to have_http_status(302)
        end
        it 'should render edit page' do
          do_update_patch
          expect(response).to redirect_to (edit_account_path(anchor: ''))
        end
      end
    end

  end

end
