class HomeController < ApplicationController
  def index
    if params[:set_locale]
      redirect_to root_path(:locale => params[:set_locale])
    else
      @time = l Time.now, :format => :long
      @cert_count_all = Certificate.count
      if user_signed_in?
        @cert_count_cur = current_user.certificates.count
        if can? :create, User
          @user_count_all = User.count
        end
      end
    end
  end
  def about
  end
end
