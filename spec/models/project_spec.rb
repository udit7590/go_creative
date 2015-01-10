require 'rails_helper'

RSpec.describe Project, type: :model do

  context 'validations' do

    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:amount_required) }
    it { should validate_presence_of(:min_amount_per_contribution) }
    it { should validate_presence_of(:end_date) }

    # it { should validate_uniqueness_of(:title) }

    it { should ensure_length_of(:title).is_at_most(250) }
    it { should ensure_length_of(:description).is_at_most(10000) }

    it { should validate_numericality_of(:amount_required).is_greater_than(0).is_less_than_or_equal_to(10000000) }
    # it { should validate_numericality_of(:min_amount_per_contribution).is_greater_than(0).is_less_than_or_equal_to(:amount_required) }

    # Custom Validators
    it { should allow_value(1000).for(:amount_required) }
    # it { should allow_value(1000).for(:min_amount_per_contribution) }
    it { should_not allow_value(99).for(:amount_required) }
    it { should_not allow_value(10).for(:amount_required) }
    # it { should_not allow_value(98).for(:min_amount_per_contribution) }
    # it { should_not allow_value(55).for(:min_amount_per_contribution) }

    it { should allow_value(5.days.from_now.beginning_of_day).for(:end_date) }
    it { should allow_value(7.days.from_now.beginning_of_day).for(:end_date) }
    it { should_not allow_value(4.days.from_now.beginning_of_day).for(:end_date) }

  end

  context 'callbacks' do
    #DISCUSS: Can't include PROC here
    it { should callback(:set_time_to_midnight).before(:create) }
    it { should callback(:set_time_to_midnight).before(:update) }
  end

  context 'associations' do
    it { should accept_nested_attributes_for :images }
    it { should accept_nested_attributes_for :legal_documents }
    it { should belong_to(:user) }
    it { should have_many(:comments) }
    it { should have_many(:images).conditions(document: false) }
    it { should have_many(:legal_documents).conditions(document: true).class_name('Image') }
  end

  context 'paperclip' do
    it { should have_attached_file(:project_picture) }
    # it { should validate_attachment_presence(:project_picture) }
    it { should validate_attachment_content_type(:project_picture).
                  allowing('image/png', 'image/gif', 'image/jpg', 'image/jpeg').
                  rejecting('text/plain', 'text/xml') }
    # it { should validate_attachment_size(:project_picture).less_than(2.megabytes) }
  end

  context 'scopes' do
    ActiveRecord::Base.transaction do
      before do
        @projectA = Project.create!(type: 'CharityProject', title: 'ABCa', description: 'ABCB', amount_required: 1000, min_amount_per_contribution: 10, end_date: 6.days.from_now.beginning_of_day, state: :published)
        @projectB = Project.create!(type: 'CharityProject', title: 'ABCb', description: 'ABCB', amount_required: 1000, min_amount_per_contribution: 10, end_date: 6.days.from_now.beginning_of_day, state: :published)
        @projectC = Project.create!(type: 'InvestmentProject', title: 'ABCc', description: 'ABCB', amount_required: 1000, min_amount_per_contribution: 10, end_date: 6.days.from_now.beginning_of_day, state: :created)
        @projectD = Project.create!(type: 'InvestmentProject', title: 'ABCd', description: 'ABCB', amount_required: 1000, min_amount_per_contribution: 10, end_date: 6.days.from_now.beginning_of_day, state: :unpublished)
      end
      
      it 'should return charity projects' do
        expect(Project.charity).to eq([@projectA, @projectB])
      end

      it 'should return investment projects' do
        expect(Project.investment).to eq([@projectC, @projectD])
      end

      it 'should return projects by creation date' do
        expect(Project.order_by_creation).to eq([@projectD, @projectC, @projectB, @projectA])
      end

      it 'should return projects that are yet to be approved' do
        expect(Project.projects_to_be_approved).to eq([@projectD, @projectC])
      end

      it 'should return best projects' do
        expect(Project.best_projects).to eq([@projectB, @projectA])
      end

      it 'should return published charity projects' do
        expect(Project.published_charity_projects).to eq([@projectB, @projectA])
      end

      it 'should return published charity projects' do
        expect(Project.published_investment_projects).to eq([])
      end

      it 'should return page wise project records' do
        expect(Project.limit_records(1)).to eq([@projectA, @projectB, @projectC, @projectD])
      end

      it 'should return page wise project records' do
        expect(Project.limit_records(2)).to eq([])
      end

      raise ActiveRecord::Rollback

    end
    
    context 'state machine' do
      before do
        @project1 = Project.create!(type: 'CharityProject', title: 'XYZ', description: 'ABCB', amount_required: 1000, min_amount_per_contribution: 10, end_date: 6.days.from_now.beginning_of_day, state: :created)
        @project2 = Project.create!(type: 'CharityProject', title: 'PQR', description: 'ABCB', amount_required: 1000, min_amount_per_contribution: 10, end_date: 6.days.from_now.beginning_of_day, state: :published)
        @project3 = Project.create!(type: 'CharityProject', title: 'LMN', description: 'ABCB', amount_required: 1000, min_amount_per_contribution: 10, end_date: 6.days.from_now.beginning_of_day, state: :unpublished)
      end

      after do
        Project.delete_all
      end

      it 'should publish the project' do
        expect{ @project1.publish! }.to change{ @project1.state }.from(:created).to('published')
      end

      it 'should publish the project from unpublished' do
        expect{ @project3.publish! }.to change{ @project3.state }.from(:unpublished).to('published')
      end

      it 'should unpublish the project' do
        expect{ @project2.unpublish! }.to change{ @project2.state }.from(:published).to('unpublished')
      end

    end
  
  end

end
