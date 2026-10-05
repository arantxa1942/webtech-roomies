# db/seeds.rb

puts "Limpiando la base de datos..."
# Se destruyen en orden inverso a sus dependencias
[Review, Visit, Application, PropertyAmenity, Amenity, Listing, Property, Neighborhood, User].each do |model|
  model.destroy_all if defined?(model)
end

puts "Creando Barrios (Neighborhoods)..."
providencia = Neighborhood.create!(name: "Providencia", city: "Santiago", zip_code: "7500000")
las_condes  = Neighborhood.create!(name: "Las Condes", city: "Santiago", zip_code: "7550000")
santiago_c  = Neighborhood.create!(name: "Santiago Centro", city: "Santiago", zip_code: "8320000")
ñuñoa       = Neighborhood.create!(name: "Ñuñoa", city: "Santiago", zip_code: "7750000")

puts "Creando Usuarios (Seekers y Hosts)..."
host1 = User.create!(name: "Carlos Mendoza", email: "carlos@roomies.cl", role: "host")
host2 = User.create!(name: "Valeria Gómez", email: "valeria@roomies.cl", role: "host")

seeker1 = User.create!(name: "Mateo Silva", email: "mateo@gmail.com", role: "seeker")
seeker2 = User.create!(name: "Camila Rojas", email: "camila@gmail.com", role: "seeker")
seeker3 = User.create!(name: "Lucas Fernandez", email: "lucas@gmail.com", role: "seeker")

puts "Creando Amenidades..."
wifi       = Amenity.create!(name: "High-Speed Wi-Fi", icon: "wifi")
gym        = Amenity.create!(name: "Gimnasio", icon: "activity")
pool       = Amenity.create!(name: "Piscina", icon: "sun")
ac         = Amenity.create!(name: "Aire Acondicionado", icon: "wind")
pet_friend = Amenity.create!(name: "Pet Friendly", icon: "heart")

puts "Creando Propiedades..."
prop1 = Property.create!(
  title: "Departamento Amoblado cerca del Metro Manuel Montt",
  description: "Espacioso departamento de 3 dormitorios, excelente conectividad y vista despejada.",
  address: "Av. Providencia 1234, Apt 502",
  neighborhood: providencia,
  user: host1
)

prop2 = Property.create!(
  title: "Moderno Penthouse en El Golf",
  description: "Propiedad de alto estándar con terraza panorámica, estacionamiento y seguridad 24/7.",
  address: "Isidora Goyenechea 3400",
  neighborhood: las_condes,
  user: host2
)

prop3 = Property.create!(
  title: "Casona Histórica Remodelada",
  description: "Casa compartida ideal para estudiantes o profesionales jóvenes a pasos de Barrio Italia.",
  address: "Av. Italia 890",
  neighborhood: ñuñoa,
  user: host1
)

puts "Asociando Amenidades a Propiedades (N:M)..."
prop1.amenities << [wifi, ac, pet_friend]
prop2.amenities << [wifi, gym, pool, ac]
prop3.amenities << [wifi, pet_friend]

puts "Creando Publicaciones / Habitaciones (Listings)..."
# Propiedad 1 con 2 publicaciones
listing1 = Listing.create!(
  property: prop1,
  title: "Habitación Principal con Baño Privado",
  description: "Habitación luminosa con cama King, closet amplio y escritorio.",
  rent: 380000,
  deposit: 380000,
  minimum_stay: 6, # meses
  available_from: Date.today + 5.days,
  status: :published # enum
)

listing2 = Listing.create!(
  property: prop1,
  title: "Habitación Individual Amoblada",
  description: "Ideal para estudiante, incluye gastos comunes.",
  rent: 280000,
  deposit: 200000,
  minimum_stay: 3,
  available_from: Date.today + 10.days,
  status: :published
)

# Propiedad 2 (En revisión / Borrador para mostrar estados de lifecycle)
listing3 = Listing.create!(
  property: prop2,
  title: "Suite de Lujo en Las Condes",
  description: "Habitación con baño en suite y acceso a piscina.",
  rent: 550000,
  deposit: 550000,
  minimum_stay: 12,
  available_from: Date.today + 15.days,
  status: :draft
)

# Propiedad 3 (Archivada / Rentada)
listing4 = Listing.create!(
  property: prop3,
  title: "Habitación en Barrio Italia",
  description: "Gran ambiente universitario y cerca del metro.",
  rent: 250000,
  deposit: 250000,
  minimum_stay: 4,
  available_from: Date.today - 30.days,
  status: :archived
)

puts "Creando Postulaciones (Applications)..."
# Competencia por listing1
app1 = Application.create!(
  listing: listing1,
  user: seeker1,
  message: "¡Hola! Me interesa mucho la habitación, trabajo de forma híbrida y soy muy ordenado.",
  status: :pending # enum
)

app2 = Application.create!(
  listing: listing1,
  user: seeker2,
  message: "Hola Carlos, busco lugar urgente a partir del próximo mes. Cuento con excelentes referencias.",
  status: :accepted
)

# Postulación para listing2
app3 = Application.create!(
  listing: listing2,
  user: seeker3,
  message: "Estimados, quisiera coordinar una visita la próxima semana si sigue disponible.",
  status: :rejected
)

puts "Creando Visitas (Visits)..."
# La regla de validación exige que la visita sea posterior a la postulación
Visit.create!(
  application: app2,
  scheduled_at: Time.current + 2.days,
  status: :completed, # enum
  notes: "Visita realizada con éxito, el postulante cumplió con los requisitos."
)

Visit.create!(
  application: app1,
  scheduled_at: Time.current + 4.days,
  status: :scheduled,
  notes: "Visita agendada para el jueves por la tarde."
)

puts "Creando Reseñas (Reviews)..."
Review.create!(
  property: prop1,
  user: seeker2,
  rating: 5,
  comment: "Excelente propiedad, tal cual las fotos. Carlos es un gran anfitrión y la ubicación es inmejorable."
)

Review.create!(
  property: prop3,
  user: seeker3,
  rating: 4,
  comment: "Muy bonita la casona y el barrio es increíble, aunque un poco ruidoso los fines de semana."
)

puts "¡Base de datos poblada exitosamente con éxito!"