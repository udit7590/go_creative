json.is_more_comments_available @is_more_available

json.comments @comments do |comment|
  
  json.id comment.id
  json.description comment.description
  json.updated_at comment.updated_at.to_s(:short)
  json.abused_count comment.abused_count
  json.spam comment.spam
  json.admin_user_id comment.admin_user_id

  if @admin
    json.delete_path admin_comment_path(comment.id)
    json.delete_method 'delete'
  end

  json.project do
    json.id comment.project.id
  end

  json.user do
    if comment.user
      json.name comment.user.name
      json.email comment.user.email
      json.id comment.user.id
    else
      json.name 'Admin'
      json.email 'contact@booleans.in'
      json.id comment.admin_user_id
    end
  end

end
