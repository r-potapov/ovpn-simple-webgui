class ApplicationController < ActionController::Base
  before_filter :set_i18n_locale_from_params
  before_filter :banned?

  protect_from_forgery
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end

  protected
  def set_i18n_locale_from_params
    if params[:locale]
      if I18n.available_locales.include?(params[:locale].to_sym)
        I18n.locale = params[:locale]
      else
        flash.now[:notice] = "#{params[:locale]} translation not available"
        logger.error flash.now[:notice]
      end
    end
  end

  def default_url_options
    { :locale => I18n.locale }
  end
  
  def banned?
    if current_user.present? && current_user.banned?
      sign_out current_user
      flash[:error] = t(:user_banned)
      redirect_to root_url
    end
  end

end
