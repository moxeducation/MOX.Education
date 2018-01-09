json.name @tag.name

json.image do
  json.small @tag.image.to_s(:small)
  json.medium @tag.image.to_s(:medium)
  json.large @tag.image.to_s(:large)
  json.original @tag.image.to_s
end
