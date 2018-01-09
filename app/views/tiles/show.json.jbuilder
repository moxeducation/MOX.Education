json.partial! 'tile', tile: @tile

json.product do
  json.partial! 'product', product: @product, withoutTiles: true
end
