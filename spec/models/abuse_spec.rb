require 'rails_helper'

RSpec.describe Abuse, :type => :model do
  context 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:abusable) }
  end
end
