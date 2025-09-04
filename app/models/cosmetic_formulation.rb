class CosmeticFormulation < ApplicationRecord
  belongs_to :user
  has_many :sample_orders, dependent: :destroy
  
  validates :product_type, presence: true
  validates :skin_type, presence: true
  validates :concerns, presence: true
  validates :target_age, presence: true
  
  PRODUCT_TYPES = [
    ['スキンケア（化粧水）', 'toner'],
    ['スキンケア（乳液・クリーム）', 'moisturizer'],
    ['スキンケア（美容液）', 'serum'],
    ['スキンケア（洗顔料）', 'cleanser'],
    ['メイクアップ（ファンデーション）', 'foundation'],
    ['メイクアップ（リップ）', 'lipstick'],
    ['ヘアケア（シャンプー）', 'shampoo'],
    ['ボディケア（ローション）', 'body_lotion']
  ].freeze
  
  SKIN_TYPES = [
    ['普通肌', 'normal'],
    ['乾燥肌', 'dry'],
    ['オイリー肌', 'oily'],
    ['混合肌', 'combination'],
    ['敏感肌', 'sensitive']
  ].freeze
  
  TARGET_AGES = [
    ['10代', 'teens'],
    ['20代', 'twenties'],
    ['30代', 'thirties'],
    ['40代', 'forties'],
    ['50代以上', 'fifty_plus']
  ].freeze
  
  def product_type_name
    PRODUCT_TYPES.find { |name, value| value == product_type }&.first
  end
  
  def skin_type_name
    SKIN_TYPES.find { |name, value| value == skin_type }&.first
  end
  
  def target_age_name
    TARGET_AGES.find { |name, value| value == target_age }&.first
  end
  
  def concerns_name
    concerns.present? ? concerns : '未設定'
  end
end
