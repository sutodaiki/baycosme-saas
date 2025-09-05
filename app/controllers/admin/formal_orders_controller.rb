# frozen_string_literal: true

class Admin::FormalOrdersController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!
  before_action :set_formal_order, only: [:show, :edit, :update, :destroy]

  def index
    @formal_orders = FormalOrder.includes(:user, :company, :cosmetic_formulation, :sample)
    
    # 検索機能
    if params[:search].present?
      @formal_orders = @formal_orders.joins(:company, :user)
                                    .joins('LEFT JOIN samples ON formal_orders.sample_id = samples.id')
                                    .joins('LEFT JOIN cosmetic_formulations ON formal_orders.cosmetic_formulation_id = cosmetic_formulations.id')
                                    .where("companies.name LIKE ? OR users.name LIKE ? OR formal_orders.contact_name LIKE ? OR samples.name LIKE ? OR cosmetic_formulations.product_name LIKE ?", 
                                          "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    # ステータスフィルター
    if params[:status].present? && params[:status] != 'all'
      @formal_orders = @formal_orders.where(status: params[:status])
    end
    
    # 優先度フィルター
    if params[:priority].present? && params[:priority] != 'all'
      @formal_orders = @formal_orders.where(priority: params[:priority])
    end
    
    # 企業フィルター
    if params[:company_id].present? && params[:company_id] != 'all'
      @formal_orders = @formal_orders.where(company_id: params[:company_id])
    end
    
    # 期間フィルター
    if params[:date_from].present?
      @formal_orders = @formal_orders.where('created_at >= ?', params[:date_from])
    end
    
    if params[:date_to].present?
      @formal_orders = @formal_orders.where('created_at <= ?', params[:date_to])
    end
    
    # ソート
    case params[:sort]
    when 'company'
      @formal_orders = @formal_orders.joins(:company).order('companies.name')
    when 'priority_desc'
      @formal_orders = @formal_orders.order(
        Arel.sql("CASE priority WHEN 'urgent' THEN 3 WHEN 'high' THEN 2 ELSE 1 END DESC")
      )
    when 'cost_desc'
      @formal_orders = @formal_orders.order('total_cost DESC')
    when 'quantity_desc'
      @formal_orders = @formal_orders.order('quantity DESC')
    when 'created_asc'
      @formal_orders = @formal_orders.order(created_at: :asc)
    else
      @formal_orders = @formal_orders.order(created_at: :desc)
    end
    
    @formal_orders = @formal_orders.page(params[:page]).per(20)
    
    # 統計情報
    @stats = {
      total: FormalOrder.count,
      pending_quote: FormalOrder.pending_quote.count,
      pending_approval: FormalOrder.pending_approval.count,
      confirmed: FormalOrder.confirmed.count,
      in_progress: FormalOrder.in_progress.count,
      completed: FormalOrder.completed.count,
      cancelled: FormalOrder.cancelled.count,
      urgent: FormalOrder.where(priority: 'urgent').count,
      total_revenue: calculate_total_revenue,
      avg_order_value: calculate_avg_order_value
    }
    
    # フィルター用データ
    @companies = Company.order(:name)
  end

  def show
  end

  def edit
  end

  def update
    if @formal_order.update(formal_order_params)
      # ステータス変更時の処理
      if formal_order_params[:status] && @formal_order.status_changed?
        handle_status_change(@formal_order)
      end
      
      redirect_to admin_formal_order_path(@formal_order), notice: '正式発注が更新されました。'
    else
      render :edit
    end
  end

  def destroy
    if @formal_order.can_cancel?
      @formal_order.update(status: 'cancelled')
      redirect_to admin_formal_orders_path, notice: '正式発注がキャンセルされました。'
    else
      redirect_to admin_formal_orders_path, alert: 'この発注はキャンセルできません。'
    end
  end

  private

  def set_formal_order
    @formal_order = FormalOrder.find(params[:id])
  end

  def formal_order_params
    params.require(:formal_order).permit(:status, :priority, :quantity, :notes,
                                        :delivery_address, :contact_name, :contact_phone,
                                        :shipped_at, :delivered_at, :tracking_number,
                                        :unit_price, :manufacturing_cost, :shipping_cost, :total_cost,
                                        :estimated_delivery_date, :delivery_postal_code, :delivery_prefecture,
                                        :delivery_city, :delivery_street, :delivery_building, :use_company_address)
  end

  def calculate_total_revenue
    # 見積もり承認済み・確定済み・完了済みの発注から収益計算
    completed_orders = FormalOrder.where(status: ['quote_approval_pending', 'confirmed', 'manufacturing', 'quality_check', 'preparing_shipment', 'shipped', 'delivered'])
    completed_orders.sum do |order|
      order.calculate_total_cost
    end
  end

  def calculate_avg_order_value
    orders_with_cost = FormalOrder.where.not(total_cost: nil).where('total_cost > 0')
    return 0 if orders_with_cost.empty?
    
    total_revenue = orders_with_cost.sum(&:total_cost)
    total_revenue / orders_with_cost.count
  end

  def handle_status_change(formal_order)
    case formal_order.status
    when 'quote_approval_pending'
      # 見積もり作成完了時
      unless formal_order.total_cost.present?
        formal_order.update(total_cost: formal_order.calculate_total_cost)
      end
    when 'confirmed'
      # 注文確定時
      formal_order.update(estimated_delivery_date: 2.weeks.from_now) unless formal_order.estimated_delivery_date
    when 'shipped'
      formal_order.update(shipped_at: Time.current) unless formal_order.shipped_at
    when 'delivered'
      formal_order.update(delivered_at: Time.current) unless formal_order.delivered_at
    end
  end
end