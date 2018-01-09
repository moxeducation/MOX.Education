json.products @products do |product|
  # json.partial! 'product.json', product: product
  # speed-up without partials

  json.id product.id
  json.slug product.slug
  json.order product.order
  json.userId product.user_id

  json.approved product.approved?
  json.readyForApprove product.ready_for_approve?
  json.editable can? :edit, product
  json.approvable can? :approve, product

  json.tiles product.tiles do |tile|
    #json.partial! 'tile', tile: tile
    # speed-up without partials

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
      #json.partial! 'image', image: tile.file
      # speed-up without partials

      json.small tile.file.to_s(:small)
      json.medium tile.file.to_s(:medium)
      json.large tile.file.to_s(:large)
      json.original tile.file.to_s
    end
  end
end
