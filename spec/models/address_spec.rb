require 'rails_helper'

RSpec.describe Address, :type => :model do

  context 'validations' do
    it { should ensure_length_of(:full_address).is_at_most(250) }
    it { should ensure_length_of(:state).is_at_most(60) }
    it { should ensure_length_of(:city).is_at_most(60) }
  end

  context 'associations' do
    it { should belong_to(:user) }
  end
  
  context 'callbacks' do
    it { should callback(:delete_address_proof).before(:update).if(:full_address_changed?) }
  end

  context 'paperclip' do
    it { should have_attached_file(:address_proof) }
    it { should validate_attachment_content_type(:address_proof).
                  allowing('image/png', 'image/jpg', 'image/jpeg').
                  rejecting('text/plain', 'text/xml') }
  end

  context 'scopes' do
    ActiveRecord::Base.transaction do
      before do
        @addressA = Address.create!(full_address: 'Ashok Vihar', city: 'Delhi', state: 'Delhi', country: 'India', pincode: '110052', primary: true)
        @addressB = Address.create!(full_address: 'Ashok Vihar', city: 'Delhi', state: 'Delhi', country: 'India', pincode: '110052', primary: false)
      end
      
      it 'should return current address' do
        expect(Address.current_address).to eq(@addressB)
      end

      it 'should return primary address' do
        expect(Address.primary_address).to eq(@addressA)
      end

      raise ActiveRecord::Rollback

    end
  end
end
