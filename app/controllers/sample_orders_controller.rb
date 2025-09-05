class SampleOrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sample_order, only: [:show]
  
  def index
    @sample_orders = current_user.sample_orders
                                  .includes(:sample)
                                  .order(created_at: :desc)
                                  .page(params[:page])
                                  .per(10)
  end
  
  def show
  end
  
  def new
    @sample = Sample.find(params[:sample_id]) if params[:sample_id].present?
    @sample_order = current_user.sample_orders.build(sample: @sample)
  end
  
  def create
    @sample_order = current_user.sample_orders.build(sample_order_params)
    @sample_order.company = current_user.company if current_user.company
    @sample_order.status = 'pending'
    
    if @sample_order.save
      redirect_to @sample_order, notice: 'サンプル注文を受け付けました。'
    else
      @sample = @sample_order.sample
      render :new
    end
  end
  
  private
  
  def set_sample_order
    @sample_order = current_user.sample_orders.find(params[:id])
  end
  
  def sample_order_params
    params.require(:sample_order).permit(:sample_id, :quantity, :notes, :delivery_address, :priority, 
                                         :use_company_address, :delivery_postal_code, :delivery_prefecture, 
                                         :delivery_city, :delivery_street, :delivery_building)
  end
end