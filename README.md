# Roomies — Rails Application

## Members
* Teodoro Coz
* Matias Küpfer
* Arantxa Toledo

---

## 1. Description & Goal
*Roomies* is a Rails 8 web application designed to connect room seekers with property hosts. This iteration implements the domain data layer, associations, validations, lifecycle enums, custom scopes, and read-only views for browsing properties, listings, neighborhoods, and applications.

---

## 2. Requirements
* **Ruby:** 3.x
* **Rails:** 8.x
* **Database:** PostgreSQL
* **Styling & Bundling:** Bootstrap via `cssbundling-rails`
* **JavaScript:** Node.js & Yarn / npm

---

## 3. Setup & Installation

Follow these steps to set up the local environment, initialize the PostgreSQL database, and populate sample data:

1. **Install dependencies:**
   ```bash
   bundle install
   yarn install
Prepare database and load Seed Data:

bin/rails db:prepare
bin/rails db:seed
Run the application:

bin/dev
Open your browser at http://localhost:3000.

## 4. Seed Data Overview (db/seeds.rb)
Running bin/rails db:seed on an empty database populates the app with realistic sample data representing real Santiago neighborhoods (Providencia, Las Condes, Ñuñoa, Santiago Centro):

Complete Model Coverage: Populates Neighborhood, User (Hosts & Seekers), Property, Amenity, PropertyAmenity, Listing, Application, Visit, and Review.

Lifecycles (Enums): Demonstrates listings in draft, published, and archived states; applications in pending, accepted, and rejected states; and visits in scheduled and completed states.

Many-to-Many Associations: Properties associated with multiple amenities through join tables.

Competing Applications & Visits: Multiple seekers applying for the same room, with scheduled visits strictly dated after the application creation date.

## 5. Updated Domain Model

### Changes from Assignment 1
* **Lifecycle Enums:** Added enum status columns to `Listing` (`draft`, `published`, `archived`), `Application` (`pending`, `accepted`, `rejected`), and `Visit` (`scheduled`, `completed`, `cancelled`).
* **Database Constraints:** Added unique composite indexes for `[applicant_id, listing_id]` on `applications` to prevent duplicate applications, and for `[property_id, amenity_id]` on `property_amenities`.
* **Validations:** Added mandatory field constraints (`null: false`) for `rent`, `deposit`, `available_from`, and `rating`.

### Updated Diagram
You can view the updated relational diagram here:
[Updated Domain Model on dbdiagram.io](https://dbdiagram.io/d/6aa5ca6636f998256479d6e2)

## 6. Repository Structure
webtech-roomies/
├── app/                  # Controllers, Models, Views, Layouts, Partials
├── bin/
│   └── dev               # Development server startup script (Rails + CSS/JS bundling)
├── config/               # Routes and application configurations
├── db/
│   ├── migrate/          # Database migrations with constraints & foreign keys
│   └── seeds.rb          # Seed file with realistic, complete sample data
├── photo/                # Pictures used on the landing page
├── index.html            # Original Assignment 1 static landing page
├── user-stories.md       # User stories covering core application functionality
├── design-decisions.md   # Rationale behind architectural & domain decisions
└── README.md             # Setup guide, structure, seed info & domain model update