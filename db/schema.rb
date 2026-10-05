# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_05_004600) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "amenities", force: :cascade do |t|
    t.string "name", null: false
    t.string "category", null: false
  end

  create_table "applications", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "applicant_id", null: false
    t.text "message"
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id"], name: "index_applications_on_applicant_id"
    t.index ["listing_id"], name: "index_applications_on_listing_id"
  end

  create_table "listing_photos", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.string "image_url", null: false
    t.boolean "is_main", default: false, null: false
    t.index ["listing_id"], name: "index_listing_photos_on_listing_id"
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.string "title", null: false
    t.text "description"
    t.decimal "monthly_rent", null: false
    t.date "available_from", null: false
    t.string "status", default: "draft", null: false
    t.datetime "created_at", null: false
    t.index ["property_id"], name: "index_listings_on_property_id"
  end

  create_table "neighborhoods", force: :cascade do |t|
    t.string "name", null: false
    t.string "city", null: false
    t.index ["name", "city"], name: "index_neighborhoods_on_name_and_city", unique: true
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.bigint "neighborhood_id", null: false
    t.string "title", null: false
    t.string "address", null: false
    t.text "description"
    t.integer "bedrooms", null: false
    t.integer "bathrooms", null: false
    t.boolean "shared_spaces", default: true
    t.datetime "created_at", null: false
    t.index ["neighborhood_id"], name: "index_properties_on_neighborhood_id"
    t.index ["owner_id"], name: "index_properties_on_owner_id"
  end

  create_table "property_amenities", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "amenity_id", null: false
    t.index ["amenity_id"], name: "index_property_amenities_on_amenity_id"
    t.index ["property_id"], name: "index_property_amenities_on_property_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "reporter_id", null: false
    t.bigint "listing_id", null: false
    t.text "reason", null: false
    t.string "status", null: false
    t.bigint "moderator_id"
    t.text "moderator_notes"
    t.datetime "created_at", null: false
    t.datetime "reviewed_at"
    t.index ["listing_id"], name: "index_reports_on_listing_id"
    t.index ["moderator_id"], name: "index_reports_on_moderator_id"
    t.index ["reporter_id"], name: "index_reports_on_reporter_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "reviewer_id", null: false
    t.bigint "property_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.index ["property_id"], name: "index_reviews_on_property_id"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
    t.index ["visit_id"], name: "index_reviews_on_visit_id", unique: true
  end

  create_table "saved_listings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "listing_id", null: false
    t.datetime "saved_at", null: false
    t.index ["listing_id"], name: "index_saved_listings_on_listing_id"
    t.index ["user_id"], name: "index_saved_listings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_hash", null: false
    t.string "full_name", null: false
    t.string "phone"
    t.string "role", default: "member", null: false
    t.datetime "created_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "scheduled_at", null: false
    t.string "status", null: false
    t.text "notes"
    t.index ["application_id"], name: "index_visits_on_application_id"
  end

  add_foreign_key "applications", "listings"
  add_foreign_key "applications", "users", column: "applicant_id"
  add_foreign_key "listing_photos", "listings"
  add_foreign_key "listings", "properties"
  add_foreign_key "properties", "neighborhoods"
  add_foreign_key "properties", "users", column: "owner_id"
  add_foreign_key "property_amenities", "amenities"
  add_foreign_key "property_amenities", "properties"
  add_foreign_key "reports", "listings"
  add_foreign_key "reports", "users", column: "moderator_id"
  add_foreign_key "reports", "users", column: "reporter_id"
  add_foreign_key "reviews", "properties"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "reviews", "visits"
  add_foreign_key "saved_listings", "listings"
  add_foreign_key "saved_listings", "users"
  add_foreign_key "visits", "applications"
end
