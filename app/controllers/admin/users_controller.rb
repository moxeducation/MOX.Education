class Admin::UsersController < Admin::AdminController
  load_and_authorize_resource

  def index
    @users = @users.page params[:page]
  end

  def show
    render :edit
  end

  def edit
  end

  def update
    if @user.update_attributes user_params
      redirect_to admin_user_path(@user)
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path
  end

  protected

  def user_params
    params.require(:user).permit(:email, :company_name, :role, :notificable).tap do |p|
      if params[:user][:password].present? || params[:user][:password_confirmation].present?
        p.merge! params.require(:user).permit(:password, :password_confirmation)
      end
    end
  end
end
