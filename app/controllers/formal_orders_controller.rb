class FormalOrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_formal_order, only: [:show, :edit, :update, :destroy]
  before_action :ensure_user_company, only: [:new, :create]

  def index
    @formal_orders = current_user.formal_orders.includes(:sample, :cosmetic_formulation)
    
    # Filter by status
    if params[:status].present? && params[:status] != 'all'
      @formal_orders = @formal_orders.where(status: params[:status])
    end
    
    # Filter by priority
    if params[:priority].present? && params[:priority] != 'all'
      @formal_orders = @formal_orders.where(priority: params[:priority])
    end
    
    # Search functionality
    if params[:search].present?
      @formal_orders = @formal_orders.joins('LEFT JOIN samples ON formal_orders.sample_id = samples.id')
                                   .joins('LEFT JOIN cosmetic_formulations ON formal_orders.cosmetic_formulation_id = cosmetic_formulations.id')
                                   .where('samples.name LIKE ? OR cosmetic_formulations.product_name LIKE ? OR formal_orders.contact_name LIKE ?',
                                         "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    @formal_orders = @formal_orders.recent.page(params[:page]).per(10)
    
    # Stats for dashboard
    @stats = {
      total: current_user.formal_orders.count,
      pending_quote: current_user.formal_orders.pending_quote.count,
      pending_approval: current_user.formal_orders.pending_approval.count,
      in_progress: current_user.formal_orders.in_progress.count,
      completed: current_user.formal_orders.completed.count
    }
  end

  def show
  end

  def new
    @formal_order = current_user.formal_orders.build
    @formal_order.company = current_user.company
    @formal_order.priority = 'normal'
    @formal_order.status = 'quote_pending'
    @formal_order.use_company_address = true
    
    # Set default contact info from user
    @formal_order.contact_name = current_user.display_name
    @formal_order.contact_phone = current_user.phone
    
    # Check if coming from sample or formulation
    if params[:sample_id].present?
      @formal_order.sample = Sample.find(params[:sample_id])
    elsif params[:cosmetic_formulation_id].present?
      @formal_order.cosmetic_formulation = CosmeticFormulation.find(params[:cosmetic_formulation_id])
    end
  end

  def create
    @formal_order = current_user.formal_orders.build(formal_order_params)
    @formal_order.company = current_user.company
    @formal_order.status = 'quote_pending'
    
    if @formal_order.save
      redirect_to @formal_order, notice: '正式発注依頼を送信しました。見積もりをお待ちください。'
    else
      render :new
    end
  end

  def edit
    # Only allow editing if order hasn't been confirmed yet
    unless @formal_order.can_cancel?
      redirect_to @formal_order, alert: 'この注文は編集できません。'
      return
    end
  end

  def update
    if @formal_order.update(formal_order_params)
      redirect_to @formal_order, notice: '正式発注が更新されました。'
    else
      render :edit
    end
  end

  def destroy
    if @formal_order.can_cancel?
      @formal_order.update(status: 'cancelled')
      redirect_to formal_orders_path, notice: '正式発注をキャンセルしました。'
    else
      redirect_to @formal_order, alert: 'この注文はキャンセルできません。'
    end
  end

  private

  def set_formal_order
    @formal_order = current_user.formal_orders.find(params[:id])
  end

  def formal_order_params
    params.require(:formal_order).permit(:sample_id, :cosmetic_formulation_id, :quantity, :priority,
                                        :contact_name, :contact_phone, :notes,
                                        :use_company_address, :delivery_postal_code, :delivery_prefecture,
                                        :delivery_city, :delivery_street, :delivery_building,
                                        :estimated_delivery_date)
  end

  def ensure_user_company
    unless current_user.company
      redirect_to edit_user_registration_path, alert: '正式発注には会社情報の登録が必要です。'
    end
  end
end