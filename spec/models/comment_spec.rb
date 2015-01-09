require 'rails_helper'

RSpec.describe Comment, :type => :model do
  context 'validations' do
    it { should validate_presence_of(:description) }
    it { should ensure_length_of(:description).is_at_most(10000) }
  end

  context 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:project) }
    it { should have_many(:abused_comments).class_name('Abuse') }
  end

  context 'scopes' do
    ActiveRecord::Base.transaction do
      before do
        @commentA = Comment.create!(description: 'A', deleted: false, spam: false, visible_to_all: true)
        @commentB = Comment.create!(description: 'B', deleted: true, spam: false, visible_to_all: true)
        @commentC = Comment.create!(description: 'C', deleted: true, spam: true, visible_to_all: true)
        @commentD = Comment.create!(description: 'D', deleted: false, spam: true, visible_to_all: false)
      end
      
      it 'should return deleted comments' do
        expect(Comment.deleted(true)).to eq([@commentB, @commentC])
      end

      it 'should not return deleted comments' do
        expect(Comment.deleted(false)).to eq([@commentA, @commentD])
      end

      it 'should return safe comments' do
        expect(Comment.safe).to eq([@commentA])
      end

      it 'should return public comments' do
        expect(Comment.visible_to_all(true)).to eq([@commentA])
      end

      it 'should not return public comments' do
        expect(Comment.visible_to_all(false)).to eq([@commentD])
      end

      it 'should return comments in chronological order page wise' do
        expect(Comment.order_by_date(1)).to eq([@commentA, @commentB, @commentC, @commentD])
      end

      it 'should return latest comments which are not deleted' do
        expect(Comment.latest(1)).to eq([@commentA, @commentD])
      end

      raise ActiveRecord::Rollback

    end
  
  end
end
