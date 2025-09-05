# Create admin user
admin = Admin.find_or_create_by(email: 'admin@example.com') do |admin|
  admin.password = 'password123'
  admin.password_confirmation = 'password123'
end

puts "Admin user created with:"
puts "Email: admin@example.com"
puts "Password: password123"

# Sample data
samples = [
  {
    name: "プレミアム保湿セラム",
    product_type: "serum",
    description: "ヒアルロン酸とビタミンC誘導体を配合した高保湿美容液です。乾燥肌や小じわが気になる方におすすめです。",
    price: 3500,
    status: "available"
  },
  {
    name: "マイルドクレンジングフォーム",
    product_type: "cleanser", 
    description: "敏感肌にも優しいアミノ酸系洗浄成分を使用したクレンジングフォームです。メイクも毛穴汚れもしっかり落とします。",
    price: 2200,
    status: "available"
  },
  {
    name: "ハイドレーティング化粧水",
    product_type: "toner",
    description: "セラミドと植物エキスを配合した高保湿化粧水です。肌のキメを整え、次に使うスキンケアの浸透を高めます。",
    price: 2800,
    status: "available"
  },
  {
    name: "リッチモイスチャライザー",
    product_type: "moisturizer",
    description: "シアバターとスクワランを配合した濃厚保湿クリームです。夜のスキンケアの仕上げにおすすめです。",
    price: 4200,
    status: "available"
  },
  {
    name: "オールインワンUVクリーム",
    product_type: "sunscreen",
    description: "SPF50+/PA++++の高いUV防御効果を持ちながら、美容成分も配合したオールインワンタイプの日焼け止めです。",
    price: 3800,
    status: "available"
  },
  {
    name: "ビタミンC美容液",
    product_type: "serum",
    description: "安定型ビタミンC誘導体を15%配合した美白・エイジングケア美容液です。シミ・くすみが気になる方に。",
    price: 5200,
    status: "available"
  },
  {
    name: "エイジングケアクリーム",
    product_type: "moisturizer",
    description: "レチノール誘導体とペプチドを配合したエイジングケア専用クリームです。ハリと弾力をサポートします。",
    price: 6800,
    status: "available"
  },
  {
    name: "センシティブスキン化粧水",
    product_type: "toner",
    description: "敏感肌専用に開発された低刺激処方の化粧水です。アルコールフリー、パラベンフリーで安心してお使いいただけます。",
    price: 2400,
    status: "available"
  }
]

samples.each do |sample_data|
  Sample.find_or_create_by(name: sample_data[:name]) do |sample|
    sample.product_type = sample_data[:product_type]
    sample.description = sample_data[:description]
    sample.price = sample_data[:price]
    sample.status = sample_data[:status]
  end
end

puts "サンプルデータを作成しました: #{Sample.count}件"