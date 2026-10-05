class PagesController < ApplicationController
    def home
        @listings = Listing.published.includes(:listing_photos, property: :neighborhood).order(:available_from).limit(3)
    end
end