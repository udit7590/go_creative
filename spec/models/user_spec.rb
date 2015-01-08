require 'rails_helper'

RSpec.describe User, :type => :model do

  it 'should display admin name if it exists else User' do
    user = User.new first_name: 'Udit', last_name: 'Mittal'
    expect(user.name).to eq('Udit Mittal')
  end

  context 'validations' do
    # it { should validate_format_of(:pan_card).with('AAAAA9999A') }
    # it { should validate_format_of(:phone_number).with('99999999') }
    it { should allow_value('AAAAA9999A').for(:pan_card) }
    it { should_not allow_value('ZZZ9999A').for(:pan_card) }
    it { should_not allow_value('ZZZZZ9999A').for(:pan_card) }
    it { should allow_value('999999999').for(:phone_number) }
    it { should_not allow_value('9999999').for(:phone_number) }
    it { should_not allow_value('99999999999').for(:phone_number) }
    it { should validate_presence_of(:first_name) }
    it { should ensure_length_of(:first_name).is_at_least(2).is_at_most(50) }
  end

  context 'associations' do
    it { should accept_nested_attributes_for(:addresses).limit(2) }
    it { should have_many(:projects) }
    it { should have_many(:addresses) }
  end

  context 'paperclip' do
    it { should have_attached_file(:pan_card_copy) }
    it { should validate_attachment_content_type(:pan_card_copy).
                  allowing('image/png', 'image/jpg', 'image/jpeg').
                  rejecting('text/plain', 'text/xml') }
  end

  context 'scopes' do
    ActiveRecord::Base.transaction do
      before do
        @userA = User.create!({email: 'guy@gmail.com', password: '11111111', password_confirmation: '11111111', first_name: 'ABC', last_name: 'DEF' })
        @userB = User.create!({email: 'guy2@gmail.com', password: '11111111', password_confirmation: '11111111', first_name: 'ABC', last_name: 'DEF' })
        @userA.confirm!
        @userB.confirm!
      end
      
      it 'should order users by creation date' do
        expect(User.order_by_creation).to eq([@userB, @userA])
      end

      raise ActiveRecord::Rollback

    end
  end

  context 'methods' do
    before do
      @userC = User.create!({email: 'guy3@gmail.com', password: '11111111', password_confirmation: '11111111', first_name: 'ABC', last_name: 'DEF' })
    end

    it 'should check user pan details' do
    end
  end

end
