# == Schema Information
#
# Table name: products
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  title              :string(255)
#  approver_id        :integer
#  order              :integer
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  slug               :string(255)
#  ready_for_approve  :boolean
#

class ProductsController < ApplicationController
  load_and_authorize_resource except: [:index]

  respond_to :json

  def index
    @products = available_products
  end

  def show
  end

  def create
    @group = Group.find_by_id(params[:product][:group_id])
    head :unauthorized if @group && !@group.has_member?(current_user)
    @product.user = current_user
    @product.save

    render :show
  end

  def update
    @product.update_attributes product_params
    @product.tags = Tag.where(name: params[:product][:tags])

    render :show
  end

  def destroy
    @product.destroy
    render json: { success: true }
  end

  def update_products_order
    products_order = params[:products_order]
    products_order = Hash[products_order.map{|k, v| [ Product.find(k.to_i), v.to_i ] }]

    products_order.each do |product, order|
      authorize! :update, product

      product.update_column :order, order
    end

    redirect_to products_path
  end

  def update_tiles_order
    authorize! :update, @product

    tiles_order = params[:tiles_order]
    tiles_order = Hash[tiles_order.map{|k, v| [ @product.tiles.find(k.to_i), v.to_i ] }]

    tiles_order.each do |tile, order|
      tile.update_column :order, order
    end

    redirect_to product_path(@product)
  end

  def approve
    if current_user.role? :admin
      @product.approver_id = current_user.id
    else
      @product.ready_for_approve = true
    end
    @product.save

    NotificationsMailer.ready_for_approve(current_user, @product).deliver unless current_user.role? :admin

    render :show
  end

  def disapprove
    @product.approver_id = nil
    @product.ready_for_approve = false
    @product.save

    render :show
  end

  protected

  def product_params
    params.require(:product).permit(:group_id, tiles_attributes: [ :id, :title, :content, :file, :delete_file, :linked_product_id ])
  end
end
