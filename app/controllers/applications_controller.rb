class ApplicationsController < ApplicationController
  before_action :set_group
  before_action :set_application, only: [:accept, :decline]

  def create
    @application = Application.create_if_not_exists(group: @group, user: current_user)
    if @application
      respond_to :json
    else
      head :unprocessable_entity
    end
  end

  def accept
    @application.accept!
    head :ok
  end

  def decline
    @application.destroy
    head :ok
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_application
    @application = Application.find(params[:application_id])
  end
end
