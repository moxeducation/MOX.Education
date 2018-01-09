class PublicProductsController < ApplicationController
  layout 'public'

  def show
    @products = Product.published(params[:slug])
  end
end
