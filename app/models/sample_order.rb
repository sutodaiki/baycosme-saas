class SampleOrder < ApplicationRecord
  belongs_to :user
  belongs_to :company
  belongs_to :cosmetic_formulation

  STATUSES = [
    ['注文受付', 'pending'],
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

  validates :quantity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :status, inclusion: { in: STATUSES.map(&:last) }
  validates :priority, inclusion: { in: PRIORITIES.map(&:last) }
  validates :delivery_address, presence: true
  validates :contact_name, presence: true
  validates :contact_phone, presence: true
  validates :notes, length: { maximum: 1000 }

  scope :pending, -> { where(status: 'pending') }
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

  def pending?
    status == 'pending'
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
    %w[pending manufacturing].include?(status)
  end

  def estimated_completion_date
    return nil unless %w[manufacturing quality_check preparing_shipment].include?(status)
    
    days_to_add = case status
                  when 'manufacturing' then 7
                  when 'quality_check' then 3
                  when 'preparing_shipment' then 2
                  else 0
                  end
    
    (updated_at || created_at) + days_to_add.days
  end

  def total_cost
    base_cost = case cosmetic_formulation&.product_type
                when 'cleanser' then 1500
                when 'toner' then 2000
                when 'serum' then 3000
                when 'moisturizer' then 2500
                when 'sunscreen' then 2800
                else 2000
                end
    
    priority_multiplier = case priority
                         when 'high' then 1.5
                         when 'urgent' then 2.0
                         else 1.0
                         end
    
    (base_cost * quantity * priority_multiplier).to_i
  end
end