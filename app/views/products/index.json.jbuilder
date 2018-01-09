json.products @products do |product|
  json.partial! 'product.json', product: product
end
