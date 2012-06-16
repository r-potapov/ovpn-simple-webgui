class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.role? :admin
      # can :manage, :all
      # cannot [:new, :create, :download_key, :download_crt, :download_zip], Certificate
      can :manage, User
      can [:index, :show, :destroy], Certificate
    elsif user.role? :customer
      can :manage, Certificate do |cert|
        cert.try(:user) == user
      end
    end
    if user.role? :moderator
      can :manage, Comment
    end
    can [:index, :new, :create], Comment
  end
end
