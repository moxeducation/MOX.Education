json.merge! @group.attributes

json.admin @group.admin
json.users @group.users
json.invitations @group.invitations do |i|
  json.merge! i.attributes
  json.user i.user
end
json.applications @group.applications do |a|
  json.merge! a.attributes
  json.user a.user
end

json.products @group.products do |product|
  json.id product.id
  json.slug product.slug
  json.order product.order
  json.userId product.user_id
  json.group_id product.group_id

  json.approved product.approved?
  json.readyForApprove product.ready_for_approve?
  json.editable can? :edit, product
  json.approvable can? :approve, product

  json.tiles product.tiles.includes(:product) do |tile|
    json.id tile.id
    json.productId tile.product_id
    json.editable can? :edit, tile
    json.linkedProductId tile.linked_product_id

    json.tileType tile.tile_type
    json.color tile.color
    json.order tile.order

    json.title tile.title
    json.titleColor tile.title_color
    json.content tile.content
    json.contentFormatted tile.content_formatted

    json.file do
      json.small tile.file.to_s(:small)
      json.medium tile.file.to_s(:medium)
      json.large tile.file.to_s(:large)
      json.original tile.file.to_s
    end
  end

  json.tags product.tags.map(&:name)
end
