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
    it { should callback(:set_time_to_midnight).before(:save) }
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
        expect(Project.popular).to eq([@projectB, @projectA])
      end

      it 'should return published charity projects' do
        expect(Project.recent_published_charity).to eq([@projectB, @projectA])
      end

      it 'should return published investment projects' do
        expect(Project.recent_published_investment).to eq([])
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

  context 'instance methods' do
    let(:user) { FactoryBot.create(:user_complete) }
    let(:another_user) { FactoryBot.create(:user_complete) }
    let(:projects) do
      [
        FactoryBot.create(:published_investment_project, user: user),
        FactoryBot.create(:published_charity_project, user: another_user),
        FactoryBot.create(:unpublished_investment_project, user: user),
        FactoryBot.create(:unpublished_charity_project, user: another_user),
        FactoryBot.create(:created_investment_project, user: user),
        FactoryBot.create(:created_charity_project, user: another_user),
        FactoryBot.create(:funded_investment_project, user: another_user),
        FactoryBot.create(:funded_investment_project, user: user),
        FactoryBot.create(:successful_investment_project, user: another_user)
      ]
    end

    context '#check_end_date' do
      it 'checks end date greater than 5 days' do
        expect(projects.first.check_end_date).to eq(true)
      end
      it 'checks end date greater than 5 days' do
        expect(FactoryBot.build(:project, end_date: DateTime.current).check_end_date).to eq(false)
      end
    end

    # FIXME: Find better way instead of projects[6]
    context '#percentage_completed' do
      it 'gives percentage completed' do
        expect(projects[6].percentage_completed).to eq(10.0)
      end

      it 'gives percentage completed' do
        expect(projects[0].percentage_completed).to eq(0)
      end
    end

    context '#check_end_date' do
      it 'checks end date greater than 5 days' do
        expect(projects.first.check_end_date).to eq(true)
      end
      it 'checks end date greater than 5 days' do
        expect(FactoryBot.build(:project, end_date: DateTime.current).check_end_date).to eq(false)
      end
    end
  end

  context 'class methods' do
    let(:user) { FactoryBot.create(:user_complete) }
    let(:another_user) { FactoryBot.create(:user_complete) }
    let(:projects) do
      [
        FactoryBot.create(:published_investment_project, user: user),
        FactoryBot.create(:published_charity_project, user: another_user, end_date: 6.days.from_now),
        FactoryBot.create(:unpublished_investment_project, user: user),
        FactoryBot.create(:unpublished_charity_project, user: another_user),
        FactoryBot.create(:created_investment_project, user: user),
        FactoryBot.create(:created_charity_project, user: another_user),
        FactoryBot.create(:funded_investment_project, user: another_user, collected_amount: 20000),
        FactoryBot.create(:funded_investment_project, user: user),
        FactoryBot.create(:successful_investment_project, user: another_user)
      ]
    end
    before { projects }

    context '::sort_by' do
      it 'sorts the records by criteria: recent' do
        expect(Project.sort_by(:recent).pluck(:id)).to eq([projects[7].id, projects[6].id, projects[1].id, projects[0].id])
      end
      it 'sorts the records by criteria: popularity' do
        expect(Project.sort_by(:popularity).pluck(:id)).to eq([projects[6].id, projects[7].id, projects[1].id, projects[0].id])
      end
      it 'sorts the records by criteria: ending_soon' do
        expect(Project.sort_by(:ending_soon).pluck(:id)).to eq([projects[1].id, projects[7].id, projects[6].id, projects[0].id])
      end
      it 'sorts the records by criteria. If criteria not defined, it simply returns published projects by order of creation' do
        expect(Project.sort_by(:undefined).pluck(:id)).to eq([projects[0].id, projects[1].id, projects[6].id, projects[7].id])
      end
    end

    context '::filter_by' do
      it 'filters the records by criteria: charity' do
        expect(Project.filter_by(:charity).pluck(:id)).to eq([projects[1].id, projects[3].id, projects[5].id])
      end
      it 'filters the records by criteria: investment' do
        expect(Project.filter_by(:investment).pluck(:id)).to eq([projects[0].id, projects[2].id, projects[4].id, projects[6].id, projects[7].id, projects[8].id])
      end
      it 'filters the records by criteria: completed (successful)' do
        expect(Project.filter_by(:completed).pluck(:id)).to eq([projects[8].id])
      end
    end
  end

end
