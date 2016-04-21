class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:first_name, :last_name, :phone_number,
        :email, :password, :password_confirmation)
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:first_name, :last_name, :phone_number,
        :email, :password, :password_confirmation, :current_password)
    end
  end

  def after_update_path_for(resource)
    flash[:info] = 'Profile updated'
    dashboard_path
  end
end
