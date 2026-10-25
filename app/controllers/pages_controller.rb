class PagesController < ApplicationController
    def home
    @listings = Listing.includes(:photos_attachments).all 
    end
end