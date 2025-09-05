class SamplesController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @samples = Sample.all
    @samples = @samples.by_product_type(params[:product_type]) if params[:product_type].present?
    @samples = @samples.search(params[:search]) if params[:search].present?
    @samples = @samples.page(params[:page]).per(12)
    
    @product_types = Sample.distinct.pluck(:product_type).compact.sort
  end
  
  def show
    @sample = Sample.find(params[:id])
  end
end