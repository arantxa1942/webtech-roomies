class PropertiesController < ApplicationController
    def index
        @properties = Property.includes(:neighborhood).order(:title)
    end

    def show
        @property = Property.find(params[:id])

        @listings = @property.listings.includes(:listing_photos, property: :neighborhood).order(:available_from)

        @reviews = @property.reviews.includes(:reviewer)
    end
end