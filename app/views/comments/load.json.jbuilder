json.is_more_comments_available @is_more_available

json.comments @comments do |comment|

  json.description comment.description
  json.updated_at comment.updated_at.to_s(:short)

  json.user do
    json.name comment.user.name
    json.email comment.user.email
    json.id comment.user.id
  end

end


