json.products available_products do |product|
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

  json.tiles product.tiles.includes(:product) do |tile|
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

  json.tags product.tags.map(&:name)
end

json.currentUser do
  # json.partial! 'user.json', user: current_user || User.new
  # speed-up without partials

  user = current_user || User.new

  json.id user.id
  json.email user.email
  json.companyName user.company_name
  json.role user.role
end

json.tags Tag.for_user(current_user) do |tag|
  json.name tag.name

  json.image do
    json.small tag.image.to_s(:small)
    json.medium tag.image.to_s(:medium)
    json.large tag.image.to_s(:large)
    json.original tag.image.to_s
  end
end
