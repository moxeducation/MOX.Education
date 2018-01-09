module GroupsHelper
  def group_admin?
    @group.admin? current_user
  end

end
