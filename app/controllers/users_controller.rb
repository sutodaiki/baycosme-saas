class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  
  def show
    @formulations = @user.cosmetic_formulations.limit(5).order(created_at: :desc)
    @recent_activity = @user.cosmetic_formulations.order(created_at: :desc).limit(10)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to dashboard_path, notice: 'プロフィールを更新しました。'
    else
      render :edit
    end
  end
  
  private
  
  def set_user
    @user = current_user
  end
  
  def user_params
    params.require(:user).permit(:name, :age, :skin_type, :preferred_products, :bio, :avatar_url)
  end
end
