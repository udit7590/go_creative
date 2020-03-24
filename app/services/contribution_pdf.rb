class ContributionPDF < Prawn::Document

  CONSTANTS = {
    table_head_color: 'dddddd',
    notice_color: '3399cc',
    notice_font_size: 12,
    heading_color: 'f4733d',
    table_row_color: 'ffffff',
    table_font_size: 16,
    head_font_size: 16
  }.freeze

  attr_reader :constants

  def initialize(contribution, contribution_transaction, constants = {})
    super(top_margin: 70)
    @project = contribution.project
    @user = contribution.user
    @contribution = contribution
    @transaction = contribution_transaction
    @constants = ContributionPDF::CONSTANTS.merge(constants)

    build
  end

  def build
    header_row
    thank_you
    user_box
    contribution_box
  end

  def header_row
    # text 'Go Creative', size: 30, style: :bold, align: :center
    image "#{Rails.root}/app/assets/images/img/go-creative-logo.png", position: :center
  end

  def thank_you
    move_down 20
    text 'Thank you for your contribution. This is the receipt for your contribution', size: @constants[:notice_font_size], style: :bold, align: :center, color: @constants[:notice_color]
  end

  def user_box
    _self = self
    move_down 20
    text @user.name.humanize, size: @constants[:head_font_size], style: :bold, color: @constants[:heading_color]
    @constants
    table user_details do
      row(0).font_style = :bold
      columns(1..3).align = :left
      self.column_widths = { 0 => 40, 1 => 200, 2 => 100, 3 => 100, 4 => 100 }
      self.row_colors = [_self.constants[:table_head_color], _self.constants[:table_row_color]]
    end
  end

  def user_details
    [['User ID', 'Address', 'Phone Number', 'PAN', 'Email']] + 
    [[@user.id, @user.addresses.primary_address.to_s, @user.phone_number, @user.pan_card, @user.email]]
  end

  def contribution_box
    _self = self
    move_down 20
    text "Your Contribution Details", size: @constants[:head_font_size], style: :bold, color: @constants[:heading_color]
    table contribution_details, position: :center do
      column(0).font_style = :bold
      self.column_widths = { 0 => 240, 1 => 300 }
      self.cells.columns(0).background_color = _self.constants[:table_head_color]
    end
  end

  def contribution_details
    [['Project ID', @contribution.id], 
    ['Project Title', @project.title],
    ['Project End Date', @project.end_date.to_date.to_s(:long)],
    ['Timestamp', @contribution.created_at.to_s(:long)],
    ['Amount Contributed', ActionController::Base.helpers.number_to_currency(@transaction.try(:amount) || @contribution.amount, unit: Constants::DEFAULT_CURRENCY, precision: 0)],
    ['Contribution Status', @contribution.state.humanize],
    ['Transaction ID', @transaction.try(:authorization)]]
  end

end
