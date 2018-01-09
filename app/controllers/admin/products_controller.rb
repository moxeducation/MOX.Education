class Admin::ProductsController < Admin::AdminController
  load_and_authorize_resource

  def index
    @products = @products.page params[:page]
  end

  def show
    redirect_to "/#{@product.slug}"
  end

  def edit
    redirect_to admin_product_path(@product)
  end

  def destroy
    @product.destroy
    redirect_to :back
  end

  def approve
    @product.approver_id = current_user.id
    @product.save

    redirect_to :back
  end

  def disapprove
    @product.approver_id = nil
    @product.save

    redirect_to :back
  end
end
