json.error false

json.comment do
  
  json.user do
    if @comment.user
      json.name @comment.user.name
      json.email @comment.user.email
      json.id @comment.user.id
    else
      json.name 'Admin'
      json.email 'admin@gocreative.com'
      json.id @comment.admin_user_id
    end
  end

  json.project do
    json.id @comment.project.id
  end

  json.id @comment.id
  json.parent_id @comment.parent_id
  json.description @comment.description
  json.updated_at @comment.updated_at.to_s(:short)
  json.visible_to_all @comment.visible_to_all
  json.spam @comment.spam
  json.admin_user_id @comment.admin_user_id
  
  if @admin
    json.delete_path admin_comment_path(@comment.id)
    json.delete_method 'delete'
  end

end
