class InvitationsController < ApplicationController
  before_action :set_group
  before_action :set_invitation, only: [:accept, :decline]

  def create
    user = User.find_by_email(params[:email])
    return render plain: 'No such user found', status: :not_found unless user
    return render plain: 'User is already in the group', status: :unprocessable_entity if @group.has_member? user
    @invitation = Invitation.create_if_not_exists(user: user, group: @group)
    if @invitation
      respond_to :json
    else
      render plain: 'This user is already invited or has join request', status: :unprocessable_entity
    end
  end

  def accept
    @invitation.accept!
    head :ok
  end

  def decline
    @invitation.destroy
    head :ok
  end

  private

  def set_invitation
    @invitation = Invitation.find(params[:invitation_id])
  end

  def set_group
    @group = Group.find(params[:group_id])
  end
end
