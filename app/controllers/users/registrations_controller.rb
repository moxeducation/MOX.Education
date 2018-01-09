class Users::RegistrationsController < Devise::RegistrationsController
  clear_respond_to
  respond_to :json

  before_filter :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:company_name)
    devise_parameter_sanitizer.for(:account_update).push(:company_name)
  end

  def update_resource(resource, params)
    if params[:current_password] && params[:password] && params[:password_confirmation]
      super
    else
      resource.update_without_password(params)
    end
  end
end
