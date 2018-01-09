# == Schema Information
#
# Table name: tiles
#
#  id                :integer          not null, primary key
#  product_id        :integer
#  tile_type         :string(255)      default("text")
#  title             :string(255)
#  title_color       :string(255)
#  color             :string(255)
#  content           :text(65535)
#  order             :integer
#  created_at        :datetime
#  updated_at        :datetime
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  file_updated_at   :datetime
#  linked_product_id :integer
#

class TilesController < ApplicationController
  load_resource :product
  load_resource except: [:create]
  authorize_resource

  respond_to :json

  def index
    redirect_to product_path(@tile.product)
  end

  def show
  end

  def create
    @tile = @product.tiles.create tile_params
    redirect_to product_tile_path(@tile.product, @tile)
  end

  def update
    @tile.update_attributes tile_params
    redirect_to product_tile_path(@tile.product, @tile)
  end

  def destroy
    @tile.destroy
    render json: { success: true }
  end

  protected

  def tile_params
    params.require(:tile).permit(:title, :title_color, :color, :content, :order, :file, :delete_file, :linked_product_id)
  end
end
