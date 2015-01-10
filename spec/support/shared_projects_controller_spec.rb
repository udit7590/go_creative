shared_examples 'display published projects' do
  def do_action
    get action_name
  end

  context 'when the user is not logged in' do
    it 'should return success page' do
      do_action
      expect(response).to have_http_status(:success) # 200
    end
    it "should display the published projects" do
      do_action
      expect(response).to render_template(:all)
    end
  end

  context 'when the user is logged in' do
    login_user

    it 'should return success page' do
      do_action
      expect(response).to have_http_status(:success) # 200
    end
    it "should display the  published projects" do
      do_action
      expect(response).to render_template(:all)
    end
  end
end

shared_examples 'not logged in' do
  it 'should redirect to login page' do
    action
    expect(response).to redirect_to new_user_session_path
  end
  it 'should return redirect status' do
    action
    expect(flash[:alert]).to eq 'You need to sign in before continuing.'
  end
end

shared_examples 'logged in' do
  it 'should return success page' do
    action
    expect(response).to have_http_status(status) # 200
  end
  it 'should render the page' do
    action
    expect(response).to render_or_redirect
  end
end
