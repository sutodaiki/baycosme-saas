# frozen_string_literal: true

class Admin::CompaniesController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!

  def index
    @companies = Company.includes(:users)
    
    # 検索機能
    if params[:search].present?
      @companies = @companies.where("name LIKE ? OR address LIKE ?", 
                                   "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    # ステータスフィルター
    if params[:status].present? && params[:status] != 'all'
      @companies = @companies.where(status: params[:status])
    end
    
    # プランフィルター
    if params[:plan].present? && params[:plan] != 'all'
      @companies = @companies.where(plan: params[:plan])
    end
    
    # ソート
    case params[:sort]
    when 'name'
      @companies = @companies.order(:name)
    when 'created_desc'
      @companies = @companies.order(created_at: :desc)
    when 'created_asc'
      @companies = @companies.order(created_at: :asc)
    when 'users_count'
      @companies = @companies.left_joins(:users)
                             .group('companies.id')
                             .order('COUNT(users.id) DESC')
    else
      @companies = @companies.order(created_at: :desc)
    end
    
    @companies = @companies.page(params[:page]).per(20)
    
    # 統計情報
    @stats = {
      total: Company.count,
      active: Company.where(status: 'active').count,
      suspended: Company.where(status: 'suspended').count,
      basic_plan: Company.where(plan: 'basic').count,
      professional_plan: Company.where(plan: 'professional').count,
      enterprise_plan: Company.where(plan: 'enterprise').count
    }
  end

  def show
    @company = Company.find(params[:id])
    @users = @company.users.includes(:cosmetic_formulations)
    @recent_formulations = @company.cosmetic_formulations
                                  .includes(:user)
                                  .order(created_at: :desc)
                                  .limit(10)
  end

  def edit
    @company = Company.find(params[:id])
  end

  def update
    @company = Company.find(params[:id])
    if @company.update(company_params)
      redirect_to admin_company_path(@company), notice: '企業情報が更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @company = Company.find(params[:id])
    @company.update(status: 'deleted')
    redirect_to admin_companies_path, notice: '企業が削除されました。'
  end

  private

  def company_params
    params.require(:company).permit(:name, :address, :phone, :website, 
                                   :employee_count, :plan, :status, :description)
  end
end