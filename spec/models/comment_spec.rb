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

  context 'methods' do

    let(:user) { FactoryBot.create(:user_complete) }
    let(:another_user) { FactoryBot.create(:user_complete) }
    let(:yet_another_user) { FactoryBot.create(:user_complete) }
    let(:published_investment_project) { FactoryBot.create(:published_investment_project, user: user) }
    let!(:public_comment) { FactoryBot.create(:public_comment, project: published_investment_project, user: another_user) }

    context '#mark_deleted' do
      it 'soft deletes comment' do
        expect(public_comment.mark_deleted(another_user)).to eq(true)
      end

      it 'does not soft deletes comment if no user present' do
        expect(public_comment.mark_deleted(nil)).to eq(false)
      end
    end

    context '#abuse' do
      it 'marks the comment abused' do
        expect(public_comment.abuse(another_user)).to eq(true)
      end

      # DISCUSS: DONNO WHAT IS WRONG. CALLBACK IS CALLED. BUT NOT REFLECTED
      pending 'marks the comment abused and increase abused count' do
        expect{ public_comment.abuse(another_user) }.to change{ public_comment.abused_count }.by(1)
      end
    end

    context '#already_abused_by?' do
      it 'gives false if comment is not already abused by same user' do
        expect(public_comment.already_abused_by?(another_user)).to eq(false)
      end

      it 'gives true if comment is already abused by same user' do
        public_comment.abuse(another_user)
        expect(public_comment.already_abused_by?(another_user)).to eq(true)
      end
    end

    context '#can_be_deleted_by?' do
      it 'gives true if comment can be deleted by user' do
        expect(public_comment.can_be_deleted_by?(another_user)).to eq(true)
      end

      it 'gives true if comment can be deleted by project owner' do
        expect(public_comment.can_be_deleted_by?(user)).to eq(true)
      end

      it 'gives false if comment cannot be deleted by user' do
        expect(public_comment.can_be_deleted_by?(yet_another_user)).to eq(false)
      end
    end

  end

end
