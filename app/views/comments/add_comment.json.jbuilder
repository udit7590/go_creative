json.error false

json.comment do
  
  json.user do
    json.name @comment.user.name
    json.email @comment.user.email
    json.id @comment.user.id
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

  json.delete_path comment_delete_path(@comment.id)

end
