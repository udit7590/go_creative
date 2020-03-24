require 'rails_helper'

RSpec.describe Image, :type => :model do

  context 'associations' do
    it { should accept_nested_attributes_for :imageable }
    it { should belong_to(:imageable) }
  end

  context 'paperclip' do
    # DISCUSS: Cannot test conditions for shoulda matchers paperclip
    it { should have_attached_file(:image) }
    it { should validate_attachment_content_type(:image).
                  allowing('image/png', 'image/jpg', 'image/jpeg').
                  rejecting('text/plain', 'text/xml') }
    # it { should validate_attachment_content_type(:image).
    #               allowing('image/png', 'image/jpg', 'image/jpeg', 'application/pdf').
    #               rejecting('text/plain', 'text/xml').
    #               conditions(document: true) }
    it { should validate_attachment_size(:image).less_than(2.megabytes) }
  end

  context 'scopes' do
    ActiveRecord::Base.transaction do
      before do
        @imageA = Image.create!(document: true)
        @imageB = Image.create!(document: false)
      end
      
      it 'should return documents' do
        expect(Image.documents).to eq([@imageA])
      end

      raise ActiveRecord::Rollback

    end
  end

end
