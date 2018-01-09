json.merge! @invitation.attributes
json.group do
  json.merge! @invitation.group.attributes
  json.picture_url @invitation.group.picture.url(:small)
end
json.user @invitation.user
