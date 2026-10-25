# db/seeds.rb

puts "🧹 Cleaning the database..."
[Review, Visit, Application, PropertyAmenity, Amenity, Listing, Property, Neighborhood, User].each do |model|
  model.destroy_all if defined?(model)
end

puts "🏙️ Creating Neighborhoods..."
providencia = Neighborhood.create!(name: "Providencia", city: "Santiago")
las_condes = Neighborhood.create!(name: "Las Condes", city: "Santiago")
santiago_c = Neighborhood.create!(name: "Santiago Centro", city: "Santiago")

puts "👥 Creating Users..."
host1 = User.create!(
  full_name: "Carlos Mendoza", 
  email: "carlos@roomies.cl", 
  password_hash: "hashed_password_123", 
  role: "host",
  created_at: Time.current
)
host2 = User.create!(
  full_name: "Valeria Gómez", 
  email: "valeria@roomies.cl", 
  password_hash: "hashed_password_123", 
  role: "host",
  created_at: Time.current
)

seeker1 = User.create!(
  full_name: "Mateo Silva", 
  email: "mateo@gmail.com", 
  password_hash: "hashed_password_123", 
  role: "seeker",
  created_at: Time.current
)
seeker2 = User.create!(
  full_name: "Camila Rojas", 
  email: "camila@gmail.com", 
  password_hash: "hashed_password_123", 
  role: "seeker",
  created_at: Time.current
)

puts "✨ Creating Amenities..."
wifi = Amenity.create!(name: "High-Speed ​​Wi-Fi", category: "Connectivity")
gym = Amenity.create!(name: "Gym", category: "Building")
pool = Amenity.create!(name: "Pool", category: "Building")
ac = Amenity.create!(name: "Air Conditioning", category: "Comfort")

puts "🏢 Creating Properties (using owner_id and neighborhood_id)..."
prop1 = Property.create!(
  owner_id: host1.id,
  neighborhood_id: providencia.id,
  title: "Furnished Apartment near Manuel Montt Metro Station",
  address: "Av. Providencia 1234, Apt 502",
  description: "Spacious 3-bedroom apartment.",
  bedrooms: 3,
  bathrooms: 2,
  shared_spaces: true
)
prop2 = Property.create!(
  owner_id: host2.id,
  neighborhood_id: las_condes.id,
  title: "Modern Penthouse in El Golf",
  address: "Isidora Goyenechea 3400",
  description: "High-end property with a panoramic terrace.",
  bedrooms: 2,
  bathrooms: 2,
  shared_spaces: true
)

puts "🔗 Associating Amenities with Properties..."
prop1.amenities << [wifi, ac]
prop2.amenities << [wifi, gym, pool]
puts "🛏️ Creating Listings..."
listing1 = Listing.create!(
  property_id: prop1.id,
  title: "Master Bedroom with Private Bathroom",
  description: "Bright room with a king-size bed and a desk.",
  monthly_rent: 380000,
  available_from: Date.today + 5.days,
  status: "published"
)

listing2 = Listing.create!(
  property_id: prop1.id,
  title: "Furnished Single Room",
  description: "Ideal for a student; includes common expenses.",
  monthly_rent: 280000,
  available_from: Date.today + 10.days,
  status: "published"
)

puts "📩 Creating Applications (with applicant_id)..."
app1 = Application.create!(
  listing_id: listing1.id,
  applicant_id: seeker1.id,
  message: "Hello! I am very interested in the room.",
  status: "pending"
)

app2 = Application.create!(
  listing_id: listing1.id,
  applicant_id: seeker2.id,
  message: "I am urgently looking for a place starting next month.",
  status: "accepted"
)

puts "📅 Creating Visits..."
visit1 = Visit.create!(  application_id: app2.id,
  scheduled_at: Time.current + 2.days, # Future date
  status: "completed",
  notes: "Visit successfully completed."
)

puts "⭐ Creating Reviews..."
Review.create!(
  visit_id: visit1.id,
  reviewer_id: seeker2.id,
  property_id: prop1.id,
  rating: 5,
  comment: "Excellent property and a great host."
)

puts "✅ Database successfully populated for Assignment 3!" 