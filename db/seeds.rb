require 'faker'

categories = ['Artillery', 'Mortar', 'Autocannon', 'Belt-Links', 'Data Plates']

categories.each do |cat|
  Category.create!(name: cat)
end

100.times do
  Product.create!(
    name: Faker::Commerce.product_name,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    price: rand(1500..50000),
    quantity_in_stock: rand(1..5),
    category: Category.all.sample,
    on_sale: rand(100) < 10
  )
end

puts "Created 5 categories and 100 products"