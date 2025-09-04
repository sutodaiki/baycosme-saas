# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # POST /resource
  def create
    build_resource(sign_up_params)

    # 会社情報の処理
    if resource.valid?
      begin
        ActiveRecord::Base.transaction do
          # 住所を組み立て
          address_parts = []
          address_parts << "〒#{params[:user][:company_postal_code]}" if params[:user][:company_postal_code].present?
          address_parts << params[:user][:company_prefecture] if params[:user][:company_prefecture].present?
          address_parts << params[:user][:company_city_address] if params[:user][:company_city_address].present?
          address_parts << params[:user][:company_building] if params[:user][:company_building].present?
          full_address = address_parts.join(' ')
          
          # 会社を作成
          company = Company.create!(
            name: params[:user][:company_name],
            address: full_address,
            phone: params[:user][:company_phone],
            website: params[:user][:company_website],
            employee_count: params[:user][:company_employee_count],
            created_by: nil # 後で更新
          )
          
          # ユーザーに会社を紐付け、管理者役割を設定
          resource.company = company
          resource.role = 'admin'
          
          if resource.save
            # 会社の作成者を設定
            company.update!(created_by: resource.id)
            
            # Deviseの標準処理を実行
            yield resource if block_given?
            if resource.persisted?
              if resource.active_for_authentication?
                set_flash_message! :notice, :signed_up
                sign_up(resource_name, resource)
                respond_with resource, location: after_sign_up_path_for(resource)
              else
                set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
                expire_data_after_sign_in!
                respond_with resource, location: after_inactive_sign_up_path_for(resource)
              end
            else
              clean_up_passwords resource
              set_minimum_password_length
              respond_with resource
            end
          end
        end
      rescue => e
        resource.errors.add(:base, "会社登録中にエラーが発生しました: #{e.message}")
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, :company_name, :company_postal_code, :company_prefecture, 
      :company_city_address, :company_building, :company_phone, 
      :company_website, :company_employee_count, :terms_accepted
    ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :name, :age, :skin_type, :preferred_products, :bio, :avatar_url
    ])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    mypage_path
  end
end
