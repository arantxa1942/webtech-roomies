class ListingsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :set_listing, only: %i[show edit update destroy publish withdraw mark_rented]
  before_action :load_properties, only: %i[new create edit update]
  def index
    authorize Listing
    @listings = policy_scope(Listing).published.with_attached_photos.includes(property: :neighborhood)
    @listings = @listings.in_neighborhood(params[:neighborhood_id]) if params[:neighborhood_id].present?
    @listings = @listings.under_rent(max_rent) if max_rent
    @listings = @listings.available_by(move_in_date) if move_in_date
    @listings = @listings.order(:available_from)
  end

  def show
    @amenities = @property.amenities.order(:name)
    @reviews = @property.reviews.includes(:reviewer).order(created_at: :desc)
    @application = current_user && @listing.applications.find_by(applicant_id: current_user.id)
  end

  def new
    @listing = Listing.new(property_id: params[:property_id])
    authorize @listing
  end

  def create
    @listing = Listing.new(listing_params)
    @listing.property = current_user.properties.find_by(id: params.dig(:listing, :property_id))
    @listing.status = :draft
    authorize @listing

    if @listing.save
      redirect_to @listing, notice: "Listing created as draft."
    else
      flash.now[:alert] = "Could not create the listing."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    @listing.assign_attributes(listing_params.except(:photos))
    @listing.photos.attach(new_photos) if new_photos.any?

    if @listing.errors.empty? && @listing.save
      if params[:remove_photo_ids].present?
        @listing.photos_attachments.where(id: params[:remove_photo_ids]).find_each(&:purge)
      end
      redirect_to @listing, notice: "Listing updated."
    else
      flash.now[:alert] = "Could not update the listing."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @listing.destroy
      redirect_to listings_path, status: :see_other, notice: "Listing deleted successfully."
    else
      redirect_to @listing, alert: @listing.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def publish
    change_status(:publish!, "Listing published.")
  end

  def withdraw
    change_status(:withdraw!, "Listing withdrawn.")
  end

  def mark_rented
    change_status(:mark_rented!, "Listing marked as rented.")
  end

  private

  def set_listing
    @listing = Listing.includes(property: :neighborhood).find(params[:id])
    @property = @listing.property
    authorize @listing
  end

  def load_properties
    @properties = current_user.properties.order(:title)
  end

  def change_status(action, notice)
    @listing.public_send(action)
    redirect_to @listing, notice: notice
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @listing, alert: e.record.errors.full_messages.to_sentence
  end

  def new_photos
    @new_photos ||= Array(listing_params[:photos]).compact_blank
  end

  def max_rent
    Float(params[:max_rent], exception: false) if params[:max_rent].present?
  end

  def move_in_date
    Date.iso8601(params[:move_in_date]) if params[:move_in_date].present?
  rescue ArgumentError
    nil
  end

  def listing_params
    params.require(:listing).permit(
      :title, :monthly_rent, :deposit, :available_from,
      :minimum_stay, :furnished, :private_bathroom,
      :description, :house_rules, photos: []
    )
  end
end
