json.is_more_projects_available @is_more_available

json.projects @projects do |project|

  json.title project.title
  json.truncated_title truncate(project.title)
  json.description project.description
  json.truncated_description truncate(project.description)
  json.created_at project.created_at
  json.amount_required project.amount_required
  json.end_date project.end_date
  json.end_date_display project.end_date.to_s(:long)
  json.min_amount_per_contribution project.min_amount_per_contribution
  json.type project.type
  json.verified_at project.verified_at
  json.listing_image project.project_picture.url(:medium)
  json.view_url project_path(project)

end


