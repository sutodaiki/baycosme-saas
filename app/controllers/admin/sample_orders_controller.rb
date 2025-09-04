# frozen_string_literal: true

class Admin::SampleOrdersController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!

  def index
    @sample_orders = SampleOrder.includes(:user, :company, :cosmetic_formulation)
    
    # 検索機能
    if params[:search].present?
      @sample_orders = @sample_orders.joins(:company, :user)
                                    .where("companies.name LIKE ? OR users.name LIKE ? OR sample_orders.contact_name LIKE ?", 
                                          "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    # ステータスフィルター
    if params[:status].present? && params[:status] != 'all'
      @sample_orders = @sample_orders.where(status: params[:status])
    end
    
    # 優先度フィルター
    if params[:priority].present? && params[:priority] != 'all'
      @sample_orders = @sample_orders.where(priority: params[:priority])
    end
    
    # 期間フィルター
    if params[:date_from].present?
      @sample_orders = @sample_orders.where('created_at >= ?', params[:date_from])
    end
    
    if params[:date_to].present?
      @sample_orders = @sample_orders.where('created_at <= ?', params[:date_to])
    end
    
    # ソート
    case params[:sort]
    when 'company'
      @sample_orders = @sample_orders.joins(:company).order('companies.name')
    when 'priority_desc'
      @sample_orders = @sample_orders.order(
        Arel.sql("CASE priority WHEN 'urgent' THEN 3 WHEN 'high' THEN 2 ELSE 1 END DESC")
      )
    when 'cost_desc'
      @sample_orders = @sample_orders.order('quantity DESC')
    when 'created_asc'
      @sample_orders = @sample_orders.order(created_at: :asc)
    else
      @sample_orders = @sample_orders.order(created_at: :desc)
    end
    
    @sample_orders = @sample_orders.page(params[:page]).per(20)
    
    # 統計情報
    @stats = {
      total: SampleOrder.count,
      pending: SampleOrder.pending.count,
      in_progress: SampleOrder.in_progress.count,
      completed: SampleOrder.completed.count,
      cancelled: SampleOrder.cancelled.count,
      urgent: SampleOrder.where(priority: 'urgent').count,
      total_revenue: calculate_total_revenue
    }
  end

  def show
    @sample_order = SampleOrder.find(params[:id])
  end

  def edit
    @sample_order = SampleOrder.find(params[:id])
  end

  def update
    @sample_order = SampleOrder.find(params[:id])
    
    if @sample_order.update(sample_order_params)
      # ステータス変更時の処理
      if sample_order_params[:status] && @sample_order.status_changed?
        handle_status_change(@sample_order)
      end
      
      redirect_to admin_sample_order_path(@sample_order), notice: 'サンプル注文が更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @sample_order = SampleOrder.find(params[:id])
    
    if @sample_order.can_cancel?
      @sample_order.update(status: 'cancelled')
      redirect_to admin_sample_orders_path, notice: 'サンプル注文がキャンセルされました。'
    else
      redirect_to admin_sample_orders_path, alert: 'この注文はキャンセルできません。'
    end
  end

  private

  def sample_order_params
    params.require(:sample_order).permit(:status, :priority, :quantity, :notes,
                                        :delivery_address, :contact_name, :contact_phone,
                                        :shipped_at, :delivered_at, :tracking_number)
  end

  def calculate_total_revenue
    # 簡易的な収益計算
    completed_orders = SampleOrder.where(status: ['shipped', 'delivered'])
    completed_orders.sum do |order|
      order.total_cost
    end
  end

  def handle_status_change(sample_order)
    case sample_order.status
    when 'shipped'
      sample_order.update(shipped_at: Time.current) unless sample_order.shipped_at
    when 'delivered'
      sample_order.update(delivered_at: Time.current) unless sample_order.delivered_at
    end
  end
end