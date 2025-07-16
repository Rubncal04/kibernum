Product.destroy_all
Category.destroy_all
User.destroy_all
Role.destroy_all

puts "Creating roles..."
admin_role = Role.create!(
  name: "admin",
  description: "Administrator of the system with full access"
)

user_role = Role.create!(
  name: "user",
  description: "Regular user of the system"
)

puts "Creating admin user..."
admin_user = User.create!(
  email: "admin@kibernum.com",
  password: "password123",
  password_confirmation: "password123",
  name: "Admin User",
  role: admin_role
)

puts "Creating regular user..."
regular_user = User.create!(
  email: "user@kibernum.com",
  password: "password123",
  password_confirmation: "password123",
  name: "Regular User",
  role: user_role
)

puts "Creating categories..."
electronics = Category.create!(
  name: "Electronics",
  description: "Electronics and technological products",
  created_by: admin_user
)

clothing = Category.create!(
  name: "Clothing",
  description: "Clothing and accessories",
  created_by: admin_user
)

books = Category.create!(
  name: "Books",
  description: "Books and educational material",
  created_by: admin_user
)

sports = Category.create!(
  name: "Sports",
  description: "Sports and fitness equipment",
  created_by: admin_user
)

home = Category.create!(
  name: "Home",
  description: "Home products",
  created_by: admin_user
)

puts "Creating products..."

# Productos de Electrónicos
laptop = Product.create!(
  name: "HP Pavilion Laptop",
  description: "15-inch laptop with Intel i5 processor",
  price: 899.99,
  stock: 10,
  created_by: admin_user
)

smartphone = Product.create!(
  name: "Apple iPhone 15",
  description: "Smartphone Apple with 128GB storage",
  price: 999.99,
  stock: 15,
  created_by: admin_user
)

tablet = Product.create!(
  name: "Apple iPad Air",
  description: "Tablet Apple with 10.9-inch screen",
  price: 599.99,
  stock: 8,
  created_by: admin_user
)

# Productos de Ropa
tshirt = Product.create!(
  name: "Basic T-shirt",
  description: "Cotton t-shirt in various colors",
  price: 19.99,
  stock: 50,
  created_by: admin_user
)

jeans = Product.create!(
  name: "Classic Jeans",
  description: "High-quality jeans",
  price: 49.99,
  stock: 30,
  created_by: admin_user
)

# Productos de Libros
novel = Product.create!(
  name: "The Lord of the Rings",
  description: "Complete trilogy of J.R.R. Tolkien",
  price: 29.99,
  stock: 25,
  created_by: admin_user
)

programming_book = Product.create!(
  name: "Ruby on Rails Guide",
  description: "Complete guide to learn Rails",
  price: 39.99,
  stock: 20,
  created_by: admin_user
)

# Productos de Deportes
basketball = Product.create!(
  name: "Basketball",
  description: "Official NBA ball",
  price: 79.99,
  stock: 12,
  created_by: admin_user
)

yoga_mat = Product.create!(
  name: "Yoga Mat",
  description: "Yoga mat anti-slip",
  price: 24.99,
  stock: 40,
  created_by: admin_user
)

# Productos de Hogar
coffee_maker = Product.create!(
  name: "Automatic Coffee Maker",
  description: "Programmable coffee maker with integrated grinder",
  price: 149.99,
  stock: 8,
  created_by: admin_user
)

blender = Product.create!(
  name: "Professional Blender",
  description: "Professional blender for smoothies",
  price: 89.99,
  stock: 15,
  created_by: admin_user
)

puts "Associating products with categories..."

laptop.categories << electronics
smartphone.categories << electronics
tablet.categories << electronics

# Clothing
tshirt.categories << clothing
jeans.categories << clothing

# Books
novel.categories << books
programming_book.categories << books

# Sports
basketball.categories << sports
yoga_mat.categories << sports

# Home
coffee_maker.categories << home
blender.categories << home

# Some products in multiple categories
laptop.categories << home
yoga_mat.categories << home

puts "✅ Seeds completed successfully!"
puts "✅ Summary:"
puts "   - Roles: #{Role.count}"
puts "   - Users: #{User.count}"
puts "   - Categories: #{Category.count}"
puts "   - Products: #{Product.count}"
puts "   - Product-category associations: #{Product.joins(:categories).count}"
puts ""
puts "🔑 Admin credentials:"
puts "   - admin@kibernum.com / password123"
