json.own_groups @own_groups do |g|
  json.merge! g.attributes
  json.picture_url g.picture.url(:small)
end
json.groups @groups do |g|
  json.merge! g.attributes
  json.picture_url g.picture.url(:small)
end
json.other_groups @other_groups do |g|
  json.merge! g.attributes
  json.picture_url g.picture.url(:small)
end

json.invitations @invitations do |i|
  json.merge! i.attributes
  json.group do
    json.merge! i.group.attributes
    json.picture_url i.group.picture.url(:small)
  end
  json.user i.user
end

json.applications @applications do |a|
  json.merge! a.attributes
  json.group do
    json.merge! a.group.attributes
    json.picture_url a.group.picture.url(:small)
  end
  json.user a.user
end
