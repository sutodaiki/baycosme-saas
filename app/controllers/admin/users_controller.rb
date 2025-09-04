# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!

  def index
    @users = User.includes(:company, :cosmetic_formulations)
    
    # 検索機能
    if params[:search].present?
      @users = @users.joins(:company)
                    .where("users.name LIKE ? OR users.email LIKE ? OR companies.name LIKE ?", 
                          "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    # 会社フィルター
    if params[:company_id].present? && params[:company_id] != 'all'
      @users = @users.where(company_id: params[:company_id])
    end
    
    # ロールフィルター
    if params[:role].present? && params[:role] != 'all'
      @users = @users.where(role: params[:role])
    end
    
    # ソート
    case params[:sort]
    when 'name'
      @users = @users.order(:name)
    when 'company'
      @users = @users.joins(:company).order('companies.name')
    when 'formulations_count'
      @users = @users.left_joins(:cosmetic_formulations)
                     .group('users.id')
                     .order('COUNT(cosmetic_formulations.id) DESC')
    when 'created_asc'
      @users = @users.order(created_at: :asc)
    else
      @users = @users.order(created_at: :desc)
    end
    
    @users = @users.page(params[:page]).per(20)
    
    # 統計情報
    @stats = {
      total: User.count,
      admins: User.where(role: 'admin').count,
      members: User.where(role: 'member').count,
      with_company: User.joins(:company).count,
      without_company: User.where(company: nil).count,
      active_this_month: User.joins(:cosmetic_formulations)
                             .where('cosmetic_formulations.created_at >= ?', 1.month.ago)
                             .distinct.count
    }
    
    @companies = Company.order(:name)
  end

  def show
    @user = User.find(params[:id])
    @recent_formulations = @user.cosmetic_formulations
                                .order(created_at: :desc)
                                .limit(10)
  end

  def edit
    @user = User.find(params[:id])
    @companies = Company.order(:name)
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'ユーザー情報が更新されました。'
    else
      @companies = Company.order(:name)
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.cosmetic_formulations.any?
      redirect_to admin_users_path, alert: 'このユーザーは処方データを持っているため削除できません。'
    else
      @user.destroy
      redirect_to admin_users_path, notice: 'ユーザーが削除されました。'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :role, :company_id)
  end
end