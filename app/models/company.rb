class Company < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :cosmetic_formulations, through: :users
  
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by', optional: true
  
  PLANS = [
    ['ベーシック', 'basic'],
    ['プロフェッショナル', 'professional'], 
    ['エンタープライズ', 'enterprise']
  ].freeze
  
  STATUSES = [
    ['アクティブ', 'active'],
    ['停止中', 'suspended'],
    ['削除済み', 'deleted']
  ].freeze
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :plan, inclusion: { in: PLANS.map(&:last) }
  validates :status, inclusion: { in: STATUSES.map(&:last) }
  validates :employee_count, numericality: { greater_than: 0 }, allow_blank: true
  validates :website, format: { with: URI::regexp(%w[http https]) }, allow_blank: true
  validates :phone, format: { with: /\A[\d\-\(\)\+\s]+\z/ }, allow_blank: true
  
  scope :active, -> { where(status: 'active') }
  scope :by_plan, ->(plan) { where(plan: plan) }
  
  def plan_name
    PLANS.find { |name, value| value == plan }&.first || plan
  end
  
  def status_name
    STATUSES.find { |name, value| value == status }&.first || status
  end
  
  
  def admin_users
    users.where(role: 'admin')
  end
  
  def member_users
    users.where(role: 'member')
  end
  
  def total_formulations
    cosmetic_formulations.count
  end
  
  def active?
    status == 'active'
  end
  
  def suspended?
    status == 'suspended'
  end
end
