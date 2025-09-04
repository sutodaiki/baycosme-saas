# frozen_string_literal: true

class Admins::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /admin/sign_in
  def new
    super
  end

  # POST /admin/sign_in
  def create
    super
  end

  # DELETE /admin/sign_out
  def destroy
    super
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  protected

  # The path used after signing in.
  def after_sign_in_path_for(resource)
    admin_dashboard_path
  end

  # The path used after signing out.
  def after_sign_out_path_for(resource_or_scope)
    new_admin_session_path
  end
end