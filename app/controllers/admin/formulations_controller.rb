# frozen_string_literal: true

class Admin::FormulationsController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!

  def index
    @formulations = CosmeticFormulation.includes(:user, user: :company)
    
    # 検索機能
    if params[:search].present?
      @formulations = @formulations.joins(user: :company)
                                  .where("companies.name LIKE ? OR users.name LIKE ? OR cosmetic_formulations.product_type LIKE ?", 
                                        "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    # 商品タイプフィルター
    if params[:product_type].present? && params[:product_type] != 'all'
      @formulations = @formulations.where(product_type: params[:product_type])
    end
    
    # 肌タイプフィルター
    if params[:skin_type].present? && params[:skin_type] != 'all'
      @formulations = @formulations.where(skin_type: params[:skin_type])
    end
    
    # ステータスフィルター
    if params[:status].present?
      case params[:status]
      when 'completed'
        @formulations = @formulations.where.not(formulation: [nil, ''])
      when 'pending'
        @formulations = @formulations.where(formulation: [nil, ''])
      end
    end
    
    # 期間フィルター
    if params[:date_from].present?
      @formulations = @formulations.where('created_at >= ?', params[:date_from])
    end
    
    if params[:date_to].present?
      @formulations = @formulations.where('created_at <= ?', params[:date_to])
    end
    
    # ソート
    case params[:sort]
    when 'user'
      @formulations = @formulations.joins(:user).order('users.name')
    when 'company'
      @formulations = @formulations.joins(user: :company).order('companies.name')
    when 'product_type'
      @formulations = @formulations.order(:product_type)
    when 'created_asc'
      @formulations = @formulations.order(created_at: :asc)
    else
      @formulations = @formulations.order(created_at: :desc)
    end
    
    @formulations = @formulations.page(params[:page]).per(20)
    
    # 統計情報
    @stats = {
      total: CosmeticFormulation.count,
      completed: CosmeticFormulation.where.not(formulation: [nil, '']).count,
      pending: CosmeticFormulation.where(formulation: [nil, '']).count,
      this_month: CosmeticFormulation.where('created_at >= ?', 1.month.ago).count,
      this_week: CosmeticFormulation.where('created_at >= ?', 1.week.ago).count,
      product_types: CosmeticFormulation.group(:product_type).count
    }
  end

  def show
    @formulation = CosmeticFormulation.find(params[:id])
    @sample_orders = @formulation.sample_orders.order(created_at: :desc)
  end

  def destroy
    @formulation = CosmeticFormulation.find(params[:id])
    
    if @formulation.sample_orders.any?
      redirect_to admin_formulations_path, alert: 'この処方にはサンプル注文があるため削除できません。'
    else
      @formulation.destroy
      redirect_to admin_formulations_path, notice: '処方が削除されました。'
    end
  end

  private

  def formulation_params
    params.require(:cosmetic_formulation).permit(:product_type, :skin_type, :concerns, :target_age, :formulation)
  end
end