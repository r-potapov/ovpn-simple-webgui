class Users::SessionsController < Devise::SessionsController

  def new
    super
  end

  def create
    super
  end

  def destroy
    super
  end


protected

  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && resource.banned?
      sign_out resource
      flash[:error] = t(:account_suspended)
      root_path
    else
      super
    end
   end

end
