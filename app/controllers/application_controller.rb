class ApplicationController < ActionController::Base
  before_filter :configure_devise_params, if: :devise_controller?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def configure_devise_params
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:first_name, :last_name, :email, :phone_number, :password, :password_confirmation)
    end
  end
end
