# frozen_string_literal: true

class Admin::DashboardController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!

  def index
    @total_companies = Company.count
    @total_users = User.count
    @total_formulations = CosmeticFormulation.count
    @recent_companies = Company.order(created_at: :desc).limit(10)
    @recent_formulations = CosmeticFormulation.includes(:user).order(created_at: :desc).limit(10)
    @active_companies = Company.where(status: 'active').count
    @monthly_formulations = CosmeticFormulation.where('created_at >= ?', 1.month.ago).count
  end
end