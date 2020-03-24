json.is_more_projects_available @is_more_available

json.projects @projects do |project|

  json.title project.title.html_safe
  json.truncated_title truncate(project.title, length: 25).html_safe
  json.description project.description
  json.truncated_description truncate(project.description)
  json.created_at project.created_at
  json.amount_required project.amount_required
  json.amount_required_display number_to_currency(project.amount_required, unit: Constants::DEFAULT_CURRENCY, precision: 0)
  json.end_date project.end_date
  json.end_date_display project.end_date.to_date.to_s(:short)
  json.min_amount_per_contribution project.min_amount_per_contribution
  json.percentage_completed project.percentage_completed
  json.contributors_count project.contributors_count
  json.collected_amount project.collected_amount
  json.type project.type
  json.verified_at project.verified_at
  json.listing_image project.project_picture.url(:medium)
  json.view_url project_path(project)
  json.owner = project.user_id

end


