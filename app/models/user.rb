class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  belongs_to :company, optional: true
  has_many :cosmetic_formulations, dependent: :destroy
  has_many :created_companies, class_name: 'Company', foreign_key: 'created_by', dependent: :nullify
  
  ROLES = [
    ['管理者', 'admin'],
    ['メンバー', 'member']
  ].freeze
  
  SKIN_TYPES = [
    ['普通肌', 'normal'],
    ['乾燥肌', 'dry'],
    ['オイリー肌', 'oily'],
    ['混合肌', 'combination'],
    ['敏感肌', 'sensitive']
  ].freeze
  
  validates :name, length: { maximum: 50 }
  validates :age, numericality: { greater_than: 0, less_than: 150 }, allow_blank: true
  validates :bio, length: { maximum: 500 }
  validates :role, inclusion: { in: ROLES.map(&:last) }
  
  scope :admins, -> { where(role: 'admin') }
  scope :members, -> { where(role: 'member') }
  
  def display_name
    name.present? ? name : email.split('@').first
  end
  
  def skin_type_name
    SKIN_TYPES.find { |name, value| value == skin_type }&.first || '未設定'
  end
  
  def profile_completion_percentage
    total_fields = 6
    completed_fields = 0
    
    completed_fields += 1 if name.present?
    completed_fields += 1 if age.present?
    completed_fields += 1 if skin_type.present?
    completed_fields += 1 if preferred_products.present?
    completed_fields += 1 if bio.present?
    completed_fields += 1 if avatar_url.present?
    
    (completed_fields.to_f / total_fields * 100).round
  end
  
  def formulations_this_month
    cosmetic_formulations.where('created_at >= ?', 1.month.ago).count
  end
  
  def favorite_product_type
    return '未設定' if cosmetic_formulations.empty?
    
    product_counts = cosmetic_formulations.group(:product_type).count
    most_used = product_counts.max_by { |type, count| count }&.first
    
    CosmeticFormulation::PRODUCT_TYPES.find { |name, value| value == most_used }&.first || '不明'
  end
  
  def role_name
    ROLES.find { |name, value| value == role }&.first || role
  end
  
  def admin?
    role == 'admin'
  end
  
  def member?
    role == 'member'
  end
  
  def company_name
    company&.name || '未所属'
  end
end
