# Create admin user
admin = Admin.find_or_create_by(email: 'admin@example.com') do |admin|
  admin.password = 'password123'
  admin.password_confirmation = 'password123'
end

puts "Admin user created with:"
puts "Email: admin@example.com"
puts "Password: password123"