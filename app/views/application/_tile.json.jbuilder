json.id tile.id
json.productId tile.product_id
json.editable can? :edit, tile

json.tileType tile.tile_type
json.color tile.color
json.order tile.order
json.linkedProductId tile.linked_product_id

json.title tile.title
json.titleColor tile.title_color
json.content tile.content
json.contentFormatted tile.content_formatted

json.file do
  #json.partial! 'image', image: tile.file
  # speed-up without partials

  json.small tile.file.to_s(:small)
  json.medium tile.file.to_s(:medium)
  json.large tile.file.to_s(:large)
  json.original tile.file.to_s
end
