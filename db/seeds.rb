categories = ['Artillery', 'Mortar', 'Autocannon', 'Belt-Links', 'Data Plates']

categories.each do |cat|
  Category.create!(name: cat)
end

100.times do
  Product.create!(
    name: Faker::Commerce.product_name[0..60],
    description: Faker::Lorem.paragraph(sentence_count: 3),
    price: rand(1500..50000),
    quantity_in_stock: rand(1..5),
    category: Category.all.sample,
    on_sale: rand(100) < 10
  )
end

provinces = [
  { name: "Alberta", code: "AB", gst_rate: 5.0, pst_rate: 0, hst_rate: 0 },
  { name: "British Columbia", code: "BC", gst_rate: 5.0, pst_rate: 7.0, hst_rate: 0 },
  { name: "Manitoba", code: "MB", gst_rate: 5.0, pst_rate: 7.0, hst_rate: 0 },
  { name: "New Brunswick", code: "NB", gst_rate: 0, pst_rate: 0, hst_rate: 15.0 },
  { name: "Newfoundland and Labrador", code: "NL", gst_rate: 0, pst_rate: 0, hst_rate: 15.0 },
  { name: "Northwest Territories", code: "NT", gst_rate: 5.0, pst_rate: 0, hst_rate: 0 },
  { name: "Nova Scotia", code: "NS", gst_rate: 0, pst_rate: 0, hst_rate: 14.0 },
  { name: "Nunavut", code: "NU", gst_rate: 5.0, pst_rate: 0, hst_rate: 0 },
  { name: "Ontario", code: "ON", gst_rate: 0, pst_rate: 0, hst_rate: 13.0 },
  { name: "Quebec", code: "QC", gst_rate: 5.0, pst_rate: 9.975, hst_rate: 0 },
  { name: "Prince Edward Island", code: "PE", gst_rate: 0, pst_rate: 0, hst_rate: 15.0 },
  { name: "Saskatchewan", code: "SK", gst_rate: 5.0, pst_rate: 6.0, hst_rate: 0 },
  { name: "Yukon", code: "YT", gst_rate: 5.0, pst_rate: 0, hst_rate: 0 }
]

provinces.each { |province| Province.create!(province) }
