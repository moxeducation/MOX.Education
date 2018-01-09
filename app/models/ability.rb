class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.role? :admin
      can :manage, :all
      cannot :destroy, User, id: user.id
    elsif user.persisted?
      can :create, Product
      can :manage, Product, user_id: user.id
      cannot [:approve, :disapprove], Product
      can :approve, Product, user_id: user.id
      can :manage, Tile, product: { user_id: user.id }
      can :create, Tag
    else
      can :read, :all
    end
  end
end
