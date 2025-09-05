class FormalOrder < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true
  belongs_to :cosmetic_formulation, optional: true
  belongs_to :sample, optional: true

  STATUSES = [
    ['見積もり待ち', 'quote_pending'],
    ['見積もり承認待ち', 'quote_approval_pending'],
    ['注文確定', 'confirmed'],
    ['製造中', 'manufacturing'],
    ['品質確認中', 'quality_check'],
    ['発送準備中', 'preparing_shipment'],
    ['発送済み', 'shipped'],
    ['配達完了', 'delivered'],
    ['キャンセル', 'cancelled']
  ].freeze

  PRIORITIES = [
    ['通常', 'normal'],
    ['高', 'high'],
    ['緊急', 'urgent']
  ].freeze

  validates :quantity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10000 }
  validates :status, inclusion: { in: STATUSES.map(&:last) }
  validates :priority, inclusion: { in: PRIORITIES.map(&:last) }
  validates :notes, length: { maximum: 2000 }
  
  # At least one product association is required
  validate :has_product_association
  
  # Conditional validations based on address type
  validates :delivery_address, presence: true, unless: :use_company_address?
  validates :delivery_postal_code, presence: true, unless: :use_company_address?
  validates :delivery_prefecture, presence: true, unless: :use_company_address?
  validates :delivery_city, presence: true, unless: :use_company_address?
  validates :delivery_street, presence: true, unless: :use_company_address?

  # Contact information required for formal orders
  validates :contact_name, presence: true
  validates :contact_phone, presence: true

  scope :pending_quote, -> { where(status: 'quote_pending') }
  scope :pending_approval, -> { where(status: 'quote_approval_pending') }
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :in_progress, -> { where(status: ['manufacturing', 'quality_check', 'preparing_shipment']) }
  scope :completed, -> { where(status: ['shipped', 'delivered']) }
  scope :cancelled, -> { where(status: 'cancelled') }
  
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :recent, -> { order(created_at: :desc) }

  def status_name
    STATUSES.find { |name, value| value == status }&.first || status
  end

  def priority_name
    PRIORITIES.find { |name, value| value == priority }&.first || priority
  end

  def pending_quote?
    status == 'quote_pending'
  end

  def pending_approval?
    status == 'quote_approval_pending'
  end

  def confirmed?
    status == 'confirmed'
  end

  def in_progress?
    %w[manufacturing quality_check preparing_shipment].include?(status)
  end

  def completed?
    %w[shipped delivered].include?(status)
  end

  def cancelled?
    status == 'cancelled'
  end

  def can_cancel?
    %w[quote_pending quote_approval_pending confirmed manufacturing].include?(status)
  end

  def estimated_completion_date
    return estimated_delivery_date if estimated_delivery_date.present?
    return nil unless %w[confirmed manufacturing quality_check preparing_shipment].include?(status)
    
    days_to_add = case status
                  when 'confirmed' then 14
                  when 'manufacturing' then 10
                  when 'quality_check' then 3
                  when 'preparing_shipment' then 2
                  else 0
                  end
    
    (updated_at || created_at) + days_to_add.days
  end

  def use_company_address?
    use_company_address == true
  end
  
  def delivery_full_address
    if use_company_address?
      company = user&.company
      return "会社情報が設定されていません" unless company
      
      address_parts = []
      address_parts << "〒#{company.postal_code}" if company.postal_code.present?
      address_parts << company.address if company.address.present?
      address_parts.join("\n")
    else
      address_parts = []
      address_parts << "〒#{delivery_postal_code}" if delivery_postal_code.present?
      
      location = [delivery_prefecture, delivery_city, delivery_street].compact.join('')
      address_parts << location if location.present?
      address_parts << delivery_building if delivery_building.present?
      
      address_parts.join("\n")
    end
  end

  def product_name
    if sample
      sample.name
    elsif cosmetic_formulation
      cosmetic_formulation.product_name
    else
      "カスタム製品"
    end
  end

  def product_type_name
    if sample
      sample.product_type
    elsif cosmetic_formulation
      cosmetic_formulation.product_type_name
    else
      "カスタム"
    end
  end

  def calculate_total_cost
    return total_cost if total_cost.present?
    
    base_unit_price = unit_price.presence || calculate_unit_price
    manufacturing = manufacturing_cost.presence || calculate_manufacturing_cost
    shipping = shipping_cost.presence || calculate_shipping_cost
    
    (base_unit_price * quantity) + manufacturing + shipping
  end

  private

  def has_product_association
    unless sample.present? || cosmetic_formulation.present?
      errors.add(:base, "サンプルまたは処方のいずれかを指定してください")
    end
  end

  def calculate_unit_price
    if sample&.price.present?
      sample.price * 10 # Formal order multiplier
    elsif cosmetic_formulation&.product_type.present?
      case cosmetic_formulation.product_type
      when 'cleanser' then 15000
      when 'toner' then 20000
      when 'serum' then 30000
      when 'moisturizer' then 25000
      when 'sunscreen' then 28000
      else 20000
      end
    else
      20000
    end
  end

  def calculate_manufacturing_cost
    base_cost = quantity * 500 # Base manufacturing cost per unit
    
    priority_multiplier = case priority
                         when 'high' then 1.3
                         when 'urgent' then 1.8
                         else 1.0
                         end
    
    (base_cost * priority_multiplier).to_i
  end

  def calculate_shipping_cost
    # Simple shipping cost calculation
    case quantity
    when 1..10 then 1000
    when 11..50 then 2000
    when 51..100 then 3000
    else 5000
    end
  end
end