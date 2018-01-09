class GroupsController < ApplicationController
  layout 'application_new'

  before_action :set_group, only: [:show, :update, :destroy]

  def index
    @own_groups = current_user.own_groups
    @groups = current_user.groups
    @other_groups = Group.not_associated_with_user(current_user)
    @invitations = current_user.invitations
    @applications = current_user.applications
    respond_to do |format|
      format.json { }
      format.html { redirect_to :root }
    end
  end

  def show
    respond_to do |format|
      format.json { }
      format.html { redirect_to :root }
    end
  end

  def create
    @group = Group.new(group_params.merge(admin: current_user))

    if @group.save
      respond_to :json
    else
      head :unprocessable_entity
    end
  end

  def update
    return head :forbidden unless @group.admin? current_user
    if @group.update(group_params)
      respond_to :json
    else
      head :internal_server_error
    end
  end

  def destroy
    return head :forbidden unless @group.admin? current_user
    if @group.destroy
      head :ok
    else
      head :internal_server_error
    end
  end

  private

  def set_group
    @group = Group.find(params[:id] || params[:group_id])
  end

  def group_params
    params.permit(:name, :picture)
  end
end
