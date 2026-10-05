class ListingsController < ApplicationController
    def index
        @listings = Listing.published.includes(:listing_photos, property: :neighborhood).order(:available_from)
    end

    def show
        @listing = Listing.find(params[:id])
        @property = @listing.property
        @amenities = @property.amenities
        @reviews = @property.reviews.includes(:reviewer)
        @photos = @listing.listing_photos.order(is_main: :desc, id: :asc)
    end
end
