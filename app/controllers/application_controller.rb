class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout :determine_layout

  def available_products
    if current_user.present?
      if current_user.role? :admin
        Product.shared
      else
        Product.shared.for_user(current_user.id)
      end
    else
      Product.shared.approved
    end
  end

  helper_method :available_products

  def random_tiles count=200
    Tile.where(tile_type: 'image').approved.random.select { |t| t.file.exists? }.first(count)
  end

  helper_method :random_tiles

  protected

  def determine_layout
    user_signed_in? ? 'application' : 'unauthorized'
  end
end
