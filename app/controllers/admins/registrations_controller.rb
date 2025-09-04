# frozen_string_literal: true

class Admins::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /admin/sign_up
  def new
    super
  end

  # POST /admin
  def create
    super
  end

  # GET /admin/edit
  def edit
    super
  end

  # PUT /admin
  def update
    super
  end

  # DELETE /admin
  def destroy
    super
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  protected

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    admin_dashboard_path
  end

  # The path used after successful account update.
  def after_update_path_for(resource)
    admin_dashboard_path
  end
end