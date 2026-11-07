class PagesController < ApplicationController
  skip_after_action :verify_authorized
  allow_unauthenticated_access only: :home

  def home
    @listings = Listing.published.with_attached_photos.includes(property: :neighborhood).order(:available_from).limit(3)
  end
end
