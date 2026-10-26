class ListingsController < ApplicationController
  before_action :set_listing, only: %i[show edit update destroy]

  def index
    @listings = Listing.published.with_attached_photos
                       .includes(property: :neighborhood).order(:available_from)
  end

  def show
    @property = @listing.property
    @amenities = @property.amenities
    @reviews = @property.reviews.includes(:reviewer)
  end

  def new
   @properties = current_user.properties.order(:title)
   @listing = Listing.new(property_id: params[:property_id])
  end

  def create
    property = current_user.properties.find(listing_params[:property_id])
    @listing = property.listings.build(listing_params.except(:property_id))
    @listing.status = :draft
    if @listing.save
      redirect_to @listing, notice: "Listing created."
    else
      flash.now[:alert] = "Could not create the listing."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @listing.update(listing_params)
      redirect_to @listing, notice: "Listing updated."
    else
      flash.now[:alert] = "Could not update the listing."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @listing.destroy
      redirect_to listings_path, notice: "Listing deleted."
    else
      redirect_to @listing, alert: @listing.errors.full_messages.to_sentence
    end
  end

  private

  def set_listing
    @listing = Listing.joins(:property)
                      .where(properties: { owner_id: current_user.id })
                      .or(Listing.where(status: :published))
                      .find(params[:id])
  end

  def listing_params
    params.require(:listing).permit(
      :title, :monthly_rent, :deposit, :available_from,
      :minimum_stay, :furnished, :private_bathroom,
      :description, :house_rules, photos: []
      )
  end
end