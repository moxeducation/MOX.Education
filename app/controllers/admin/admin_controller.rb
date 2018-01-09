class Admin::AdminController < ApplicationController
  before_action :authenticate_user!

  layout 'admin'

  protected

  def authenticate_user!
    redirect_to root_path unless user_signed_in? && current_user.role?(:admin)
  end
end
