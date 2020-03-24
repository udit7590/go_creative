require 'rails_helper'

RSpec.describe AdminUser, :type => :model do

  it 'should display admin name if it exists else Admin' do
    admin = AdminUser.new
    expect(admin.name).to eq('Admin')
  end
  
end
