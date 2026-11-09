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
   ```
Prepare database and load Seed Data:

bin/rails db:prepare
bin/rails db:seed
Run the application:

bin/dev
Open your browser at http://localhost:3000.

## 4. Seed Data Overview (db/seeds.rb)
Running bin/rails db:seed on an empty database populates the app with realistic sample data representing real Santiago neighborhoods (Providencia, Las Condes, Ñuñoa, Santiago Centro):

Complete Model Coverage: Populates Neighborhood, User (members and a moderator), Property, Amenity, PropertyAmenity, Listing, Application, Visit, Review, Report and SavedListing.

Lifecycles (Enums): Listings in draft, published and reserved states; applications pending, shortlisted and accepted; visits proposed and completed; reports pending and dismissed.

Many-to-Many Associations: Properties associated with multiple amenities through join tables.

Competing Applications & Visits: Multiple seekers applying for the same room, with scheduled visits strictly dated after the application creation date.

## 5. Updated Domain Model

### Changes from Assignment 1
* **Lifecycle Enums:** Added enum status columns to `Listing` (`draft`, `published`, `reserved`, `rented`, `withdrawn`), `Application` (`pending`, `shortlisted`, `accepted`, `rejected`, `withdrawn`), and `Visit` (`proposed`, `confirmed`, `cancelled`, `completed`).
* **Database Constraints:** Added unique composite indexes for `[applicant_id, listing_id]` on `applications` to prevent duplicate applications, and for `[property_id, amenity_id]` on `property_amenities`.
* **Validations:** Added numerical validations for positive `monthly_rent` and `minimum_stay`, non-negative `deposit`, and `rating` between 1 and 5. Visit dates must be after the application creation date.

### Updated Diagram
You can view the updated relational diagram here:
[Updated Domain Model on dbdiagram.io](https://dbdiagram.io/d/6aa5ca6636f998256479d6e2)

## 6. Repository Structure
webtech-roomies/
├── app/                  
├── bin/
│   └── dev               
├── config/               
├── db/
│   ├── migrate/          
│   └── seeds.rb          
├── photo/                
├── index.html            
├── user-stories.md       
├── Design Decisions.pdf  
└── README.md             

## Assignment 3 — Photos, rich text and business rules

* **Photos (Active Storage):** a listing accepts several photos. Only JPEG, PNG and WEBP
  images are accepted, with a **maximum of 5 MB per file**. Cards use the `:card` variant
  (400×300) and the listing page uses the `:large` variant (max 1200×900).
* **Rich text (Action Text):** listing description and house rules.
* **Acting as a user:** replaced in Assignment 4 by real accounts (see below).
* **Listing lifecycle:** draft → published → reserved → rented; withdrawn from draft, published or reserved.

## Assignment 4 — Accounts, roles and permissions

### Setup
```bash
bundle install
bin/rails db:reset   
bin/dev
```
Emails (password reset, application notifications) are written to `tmp/mails/` in development.

### Authentication
Native Rails 8 generator (`Session`, `Current`, `Authentication` concern) plus sign up, sign in,
sign out, password reset by email and an editable profile (name, contact details, short bio).
All views are styled with Bootstrap.

### Roles
| Role | How you get it | What it means |
|------|----------------|---------------|
| **Visitor** | Not signed in (not a value of the enum) | Can browse the landing page, search, listings, properties and reviews. Nothing else. |
| **Member** | Default for every new account | Hosts their own properties and listings, applies to other people's listings, proposes visits and writes reviews. |
| **Moderator** | Set in the database / seeds only (never from a form) | Moderators can inspect all applications and draft listings, edit or delete any property or listing, delete any review, resolve reports, and manage neighborhoods and amenities. They cannot shortlist, reject or accept applications, manage visits, or create reviews.|

### Authorization (Pundit)
Every model that users act on has a policy in `app/policies/`. Policies answer correctly when
there is no current user (visitor).

| Action | Visitor | Member | Moderator |
|---|---|---|---|
| Browse and search published listings | Yes | Yes | Yes |
| See a draft listing | No | Only their own | Yes |
| Create a property or a listing | No | Yes | Yes |
| Edit or delete a property or listing | No | Only their own | Any |
| Apply to a listing | No | Yes, except on their own | Same as a member |
| See the applications on a listing | No | On their own listings, plus the ones they wrote | Yes |
| Shortlist, reject or accept an application | No | Only on their own listings | No |
| Propose, reschedule, confirm or cancel a visit | No | Host of the listing or the applicant | No |
| Mark a visit as completed | No | Host of the listing only | No |
| Write a review | No | Only after their own completed visit | No |
| Edit a review | No | Only their own | No |
| Delete a review | No | Only their own | Any |
| Report a listing | No | Yes | Yes |
| Resolve a report | No | No | Yes |
| Manage neighborhoods and amenities | No | No (can view the lists) | Yes |
| Edit a profile | No | Only their own | Only their own |

**How it is enforced**
- **Controllers, not buttons.** Every action calls `authorize`; `after_action :verify_authorized`
  (and `verify_policy_scoped` on `index`) raises in development if one is forgotten. Buttons are
  hidden with `policy(record).action?` only as a courtesy.
- **Scopes.** The host inbox, the seeker's list of applications, the moderator's list of reports
  and the listing search are built from `policy_scope`, so the query only returns permitted records.
- **No data leaks through URLs.** Applications, visits and reports are looked up inside
  `policy_scope(...)`, so typing someone else's id returns *Not found* (we do not even confirm the
  record exists).
- **Friendly errors.** An unauthorized signed-in user sees an *Access denied* page (HTTP 403)
  explaining what they tried to do; a visitor is sent to sign in and brought back afterwards.
  Missing records show a *Not found* page (HTTP 404).
- The model is called `Application`, which clashes with Pundit's base `ApplicationPolicy`,
  so it declares `policy_class` → `RoomApplicationPolicy`.

### Seed credentials (all passwords: `password123`)
| Email | Role | Use it to check |
|-------|------|-----------------|
| `carlos@roomies.cl` | member | Host of the Providencia property: inbox with 3 applications, a **draft** listing, a reserved listing |
| `valeria@roomies.cl` | member | Host of the Las Condes property: inbox with 2 applications |
| `mateo@gmail.com` | member | Seeker: one pending application, one accepted with a completed and reviewed visit |
| `camila@gmail.com` | member | Seeker: shortlisted application with a proposed visit (can confirm or cancel it as the applicant) |
| `diego@gmail.com` | member | Seeker with a completed visit and no review yet: can write a review of Valeria's property |
| `moderator@roomies.cl` | moderator | Sees everything, a pending report to resolve, Neighborhoods and Amenities in the menu |

### Quick walkthrough
The seeds restart every id at 1, so after `bin/rails db:seed` these URLs always match:
1. **Drafts:** as Carlos open `/listings/3` (draft) → visible. As Valeria → *Access denied*. As the moderator → visible and editable. As a visitor → redirected to sign in.
2. **Applications through the URL:** as Camila open `/applications/1` (Mateo's) → *Not found*.
3. **Inboxes:** Carlos and Valeria each see only the applications on their own listings under *Applications*; Mateo, Camila and Diego see theirs under *My applications*.
4. **Visits:** as Camila open `/applications/2` → she can confirm or cancel the visit; only Carlos sees *Mark as completed*.
5. **Reviews:** as Diego open Valeria's property (`/properties/2`) → *Write a review*. As the moderator, any review shows *Delete* only.
6. **Reports:** as the moderator open *Reports* → resolve the pending one.
7. **Moderator-only pages:** as Mateo open `/neighborhoods/new` → *Access denied*.

### JSON API

The public API returns only published listings. No authentication is required.

- `GET /api/v1/listings`: lists published listings.
- `GET /api/v1/listings/:id`: shows one published listing.

Optional filters:
- `neighborhood_id`: positive integer.
- `max_rent`: maximum monthly rent in CLP.
- `move_in_date`: availability on or before this date (`YYYY-MM-DD`).

Responses contain `data`; listing collections also include `meta.count`.
Errors contain `error.code` and `error.message`.

Status codes: `200` success, `400` invalid filter, `404` missing or
unpublished listing.

The API excludes user information, application messages and exact property addresses. The landing-page search uses `fetch` to display results without reloading the page.