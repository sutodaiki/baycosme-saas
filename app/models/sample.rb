class Sample < ApplicationRecord
  validates :name, presence: true
  validates :product_type, presence: true
  validates :description, presence: true
  
  scope :by_product_type, ->(type) { where(product_type: type) if type.present? }
  scope :search, ->(query) { where("name LIKE ? OR description LIKE ?", "%#{query}%", "%#{query}%") if query.present? }
  
  def display_price
    price.present? ? "¥#{price.to_s(:delimited)}" : "お問い合わせ"
  end
  
  def available?
    status == 'available'
  end
end