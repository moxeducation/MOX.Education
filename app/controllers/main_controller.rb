class MainController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:update]

  def index
    if params[:slug].present?
      @current_product = Product.shared.where(slug: params[:slug]).first
      @current_product_tile = @current_product.tiles.first if @current_product
    end
  end

  def update
    if params[:product]
      if params[:product][:id]
        product = Product.find params[:product][:id]
        authorize! :update, product

        if params[:product][:delete]
          product.destroy
          product = nil
        else
          product.update params.require(:product).permit(:title, :image)
        end
      else
        authorize! :create, Product
        product = current_user.products.create params.require(:product).permit(:title, :image, :order)
      end

      product.editable = can? :update, product

      render json: {product: ProductSerializer.new(product).serializable_hash}
    elsif params[:tile] && params[:tile][:product_id]
      product = Product.where(id: params[:tile][:product_id])
      product = product.where(user_id: current_user.id) unless current_user.role? :admin
      product = product.first
      product.editable = can? :update, product

      render status: 404 and return unless product

      if params[:tile][:id]
        tile = Tile.find params[:tile][:id]
        authorize! :update, tile

        if params[:tile][:delete]
          tile.destroy
          tile = nil
        else
          tile.update params.require(:tile).permit(:product_id, :tile_type, :title, :title_color, :color, :content, :order, :file)
        end
      else
        authorize! :create, product.tiles.new
        tile = product.tiles.create params.require(:tile).permit(:product_id, :tile_type, :title, :title_color, :color, :content, :order, :file)
      end

      render json: { product: ProductSerializer.new(product).serializable_hash, tile: TileSerializer.new(tile).serializable_hash }
    else
      render json: {}
    end
  end

  def redirect404
    redirect_to root_path
  end
end
