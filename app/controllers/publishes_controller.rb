class PublishesController < ApplicationController

  before_action :load_product

  def create
    if @product.publish!
      render '/products/show.json', status: :ok
    else
      head 500
    end
  end

  private

  def load_product
    @product = Product.find(params[:product_id])
  end
end
