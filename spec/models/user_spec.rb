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

    let(:user) { FactoryGirl.create(:user_complete) }
    let(:user_without_name) { FactoryGirl.build(:user_without_name) }
    let(:admin) { FactoryGirl.build(:admin_user) }

    context '#name' do
      it 'gives user name' do
        expect(user.name).to eq('martin mathew')
      end

      it 'gives user string if name is blank' do
        expect(user_without_name.name).to eq('User')
      end
    end

    context '#pan_details_complete?' do
      it 'gives true if user pan details exists' do
        allow(user.pan_card_copy).to receive(:exists?).and_return(true)
        expect(user.pan_details_complete?).to eq(true)
      end

      it 'gives false if user pan details does not exist' do
        expect(user_without_name.pan_details_complete?).to eq(false)
      end
    end

    context '#pan_details_verified?' do
      it 'gives true if user pan details verified' do
        expect(user.pan_details_verified?).to eq(true)
      end

      it 'gives false if user pan details is not verified' do
        expect(user_without_name.pan_details_verified?).to eq(false)
      end
    end

    context '#primary_address_details_complete?' do
      # PENDING: Not able to stub
      pending 'gives true if user primary address details exists' do
        allow(user.addresses.primary_address.address_proof).to receive(:exists?).and_return(true)
        expect(user.primary_address_details_complete?).to eq(true)
      end

      it 'gives false if user primary address details does not exist' do
        allow(user.addresses.primary_address.address_proof).to receive(:exists?).and_return(false)
        expect(user.primary_address_details_complete?).to eq(false)
      end
    end

    context '#current_address_details_complete?' do
      # PENDING: Not able to stub
      pending 'gives true if user current details exists' do
        allow(user.addresses.current_address.address_proof).to receive(:exists?).and_return(true)
        expect(user.current_address_details_complete?).to eq(true)
      end

      it 'gives false if user current details does not exist' do
        allow(user.addresses.current_address.address_proof).to receive(:exists?).and_return(false)
        expect(user.current_address_details_complete?).to eq(false)
      end
    end
    
    context '#verified?' do
      it 'gives true if user details verified' do
        expect(user.verified?).to eq(true)
      end

      it 'gives false if user details are not verified' do
        expect(user_without_name.verified?).to eq(false)
      end
    end

    context '#complete?' do
      # PENDING: Not able to stub
      pending 'gives true if user details exist' do
        allow(user.addresses.primary_address.address_proof).to receive(:exists?).and_return(true)
        allow(user.pan_card_copy).to receive(:exists?).and_return(true)
        expect(user.primary_address_details_complete?).to eq(true)
      end

      it 'gives false if user details do not exist' do
        allow(user.addresses.primary_address.address_proof).to receive(:exists?).and_return(false)
        allow(user.pan_card_copy).to receive(:exists?).and_return(false)
        expect(user.primary_address_details_complete?).to eq(false)
      end
    end

    # UserVerification Logic
    context 'UserVerification::verify_details' do
      it 'verifies user if all details complete and returns true if details complete and verified' do
        expect(UserVerification.verify_details(user, admin)).to eq(true)
      end

      it 'verifies user if all details complete and returns false if details incomplete' do
        expect(UserVerification.verify_details(user_without_name, admin)).to eq(false)
      end
    end

  end

end
