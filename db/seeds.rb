<<<<<<< HEAD
puts "Cleaning the database..."
ActiveStorage::Attachment.find_each(&:purge)
[ Review, Visit, Application, PropertyAmenity, Amenity, Listing, Property, Neighborhood, User ].each do |model|
  model.destroy_all if defined?(model)
end

puts "Creating Neighborhoods..."
providencia = Neighborhood.create!(name: "Providencia", city: "Santiago")
las_condes = Neighborhood.create!(name: "Las Condes", city: "Santiago")
santiago_c = Neighborhood.create!(name: "Santiago Centro", city: "Santiago")

puts "Creating Users..."
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

puts "Creating Amenities..."
wifi = Amenity.create!(name: "High-Speed ​​Wi-Fi", category: "Connectivity")
gym = Amenity.create!(name: "Gym", category: "Building")
pool = Amenity.create!(name: "Pool", category: "Building")
ac = Amenity.create!(name: "Air Conditioning", category: "Comfort")

puts "Creating Properties (using owner_id and neighborhood_id)..."
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

puts "Associating Amenities with Properties..."
prop1.amenities << [ wifi, ac ]
prop2.amenities << [ wifi, gym, pool ]
puts "Creating Listings..."
listing1 = Listing.create!(
  property_id: prop1.id,
  title: "Master Bedroom with Private Bathroom",
  description: "<div>Bright room with a <strong>king-size bed</strong> and a desk.</div>",
  house_rules: "<ul><li>Quiet hours after 22:00</li><li><em>No smoking</em> indoors</li></ul>",
  monthly_rent: 380000,
  deposit: 380000,
  minimum_stay: 6,
  furnished: true,
  private_bathroom: true,
  available_from: Date.today + 5.days,
  status: "published"
)

listing2 = Listing.create!(
  property_id: prop1.id,
  title: "Furnished Single Room",
  description: "<div>Ideal for a student; includes common expenses.</div>",
  house_rules: "<ul><li>No parties</li><li>Guests allowed until 23:00</li></ul>",
  monthly_rent: 280000,
  deposit: 280000,
  minimum_stay: 3,
  furnished: true,
  private_bathroom: false,
  available_from: Date.today + 10.days,
  status: "published"
)

def attach_seed_photo(listing, filename)
  path = Rails.root.join("app/assets/images", filename)
  listing.photos.attach(io: File.open(path), filename: filename, content_type: "image/jpeg")
end

attach_seed_photo(listing1, "providencia.jpeg")
attach_seed_photo(listing1, "las-condes.jpeg")
attach_seed_photo(listing2, "providencia.jpeg")

puts "Creating Applications..."
Application.create!(
  listing_id: listing1.id, applicant_id: seeker1.id,
  message: "Hello! I am very interested in the room.",
  move_in_date: Date.today + 15.days, stay_length: 6, status: "pending"
)

shortlisted_app = Application.create!(
  listing_id: listing1.id, applicant_id: seeker2.id,
  message: "I am urgently looking for a place starting next month.",
  move_in_date: Date.today + 20.days, stay_length: 12, status: "shortlisted"
)

accepted_app = Application.create!(
  listing_id: listing2.id, applicant_id: seeker1.id,
  message: "I am a student and would love this room.",
  move_in_date: Date.today + 12.days, stay_length: 10, status: "shortlisted"
)

puts "Creating Visits..."
Visit.create!(
  application: shortlisted_app,
  scheduled_at: Time.current + 3.days,
  notes: "Proposed visit for next week."
)

completed_visit = Visit.create!(
  application: accepted_app,
  scheduled_at: Time.current + 1.day,
  notes: "Visit successfully completed."
)
completed_visit.update_columns(scheduled_at: 3.days.ago, status: "completed")

accepted_app.accept!
puts "Creating Reviews..."
Review.create!(
  visit_id: completed_visit.id,
  reviewer_id: seeker1.id,
  property_id: prop1.id,
  rating: 5,
  comment: "Excellent property and a great host."
)

puts "Database successfully populated!"
=======
puts "Cleaning the database..."
[Review, Visit, Application, PropertyAmenity, Amenity, Listing, Property, Neighborhood, User].each do |model|
  model.destroy_all if defined?(model)
end

puts "Creating Neighborhoods..."
providencia = Neighborhood.create!(name: "Providencia", city: "Santiago")
las_condes = Neighborhood.create!(name: "Las Condes", city: "Santiago")
santiago_c = Neighborhood.create!(name: "Santiago Centro", city: "Santiago")

puts "Creating Users..."
host1 = User.create!(
  full_name: "Carlos Mendoza", 
  email: "carlos@roomies.cl", 
  password_hash: "password123", 
  role: "member"
)
host2 = User.create!(
  full_name: "Valeria Gómez", 
  email: "valeria@roomies.cl", 
  password_hash: "password123", 
  role: "member"
)

seeker1 = User.create!(
  full_name: "Mateo Silva", 
  email: "mateo@gmail.com", 
  password_hash: "password123", 
  role: "member"
)
seeker2 = User.create!(
  full_name: "Camila Rojas", 
  email: "camila@gmail.com", 
  password_hash: "password123", 
  role: "member"
)

puts "Creating Amenities..."
wifi = Amenity.create!(name: "High-Speed Wi-Fi", category: "Connectivity")
gym = Amenity.create!(name: "Gym", category: "Building")
pool = Amenity.create!(name: "Pool", category: "Building")
ac = Amenity.create!(name: "Air Conditioning", category: "Comfort")

puts "Creating Properties..."
prop1 = Property.create!(
  owner: host1,
  neighborhood: providencia,
  title: "Furnished Apartment near Manuel Montt Metro Station",
  address: "Av. Providencia 1234, Apt 502",
  description: "Spacious 3-bedroom apartment.",
  bedrooms: 3,
  bathrooms: 2,
  shared_spaces: true,
  property_type: "Apartment"
)
prop2 = Property.create!(
  owner: host2,
  neighborhood: las_condes,
  title: "Modern Penthouse in El Golf",
  address: "Isidora Goyenechea 3400",
  description: "High-end property with a panoramic terrace.",
  bedrooms: 2,
  bathrooms: 2,
  shared_spaces: true,
  property_type: "Penthouse"
)

puts "Associating Amenities with Properties..."
prop1.amenities << [wifi, ac]
prop2.amenities << [wifi, gym, pool]

puts "Creating Listings..."
listing1 = Listing.create!(
  property: prop1,
  title: "Master Bedroom with Private Bathroom",
  description: "Bright room with a king-size bed and a desk.",
  monthly_rent: 380000,
  deposit: 380000,
  minimum_stay: 3,
  available_from: Date.today + 5.days,
  status: "published",
  furnished: true,
  private_bathroom: true
)

listing2 = Listing.create!(
  property: prop1,
  title: "Furnished Single Room",
  description: "Ideal for a student; includes common expenses.",
  monthly_rent: 280000,
  deposit: 280000,
  minimum_stay: 2,
  available_from: Date.today + 10.days,
  status: "published",
  furnished: true,
  private_bathroom: false
)

puts "Creating Applications..."
app1 = Application.create!(
  listing: listing1,
  applicant: seeker1,
  message: "Hello! I am very interested in the room.",
  move_in_date: Date.today + 15.days,
  stay_length: 6,
  status: "pending"
)

app2 = Application.create!(
  listing: listing1,
  applicant: seeker2,
  message: "I am urgently looking for a place starting next month.",
  move_in_date: Date.today + 20.days,
  stay_length: 12,
  status: "accepted"
)

puts "Creating Visits..."
visit1 = Visit.create!(
  application: app2,
  scheduled_at: Time.current + 2.days,
  status: "completed",
  notes: "Visit successfully completed."
)

puts "Creating Reviews..."
Review.create!(
  visit: visit1,
  reviewer: seeker2,
  property: prop1,
  rating: 5,
  comment: "Excellent property and a great host."
)

puts "Database successfully populated!"
>>>>>>> f85dde4 (Assignment 4)
