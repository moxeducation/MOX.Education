json.merge! @application.attributes
json.group do
  json.merge! @application.group.attributes
  json.picture_url @application.group.picture.url(:small)
end
json.user @application.user
