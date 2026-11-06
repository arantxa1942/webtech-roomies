class ListingsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :set_listing, only: :show
  before_action :set_owned_listing, only: %i[edit update destroy publish withdraw mark_rented]
  before_action :load_properties, only: %i[new create edit update]

  def index
    @listings = Listing.published.with_attached_photos.includes(property: :neighborhood)
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
  end

  def create
    @listing = Listing.new(listing_params)
    @listing.property = current_user.properties.find_by(id: params.dig(:listing, :property_id))
    @listing.status = :draft

    if @listing.save
      redirect_to @listing, notice: "Listing created as draft."
    else
      flash.now[:alert] = "Could not create the listing."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    # Photos are attached separately: assigning an empty file field to a
    # has_many_attached would otherwise wipe every existing photo.
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

  # A draft is visible only to its host; every other state is public.
  def set_listing
    @listing = Listing.includes(property: :neighborhood).find(params[:id])
    @property = @listing.property

    return unless @listing.draft? && @property.owner_id != current_user&.id
    redirect_to listings_path, alert: "This listing is not available."
  end

  def set_owned_listing
    @listing = Listing.joins(:property)
                      .where(properties: { owner_id: current_user.id })
                      .find_by(id: params[:id])

    if @listing
      @property = @listing.property
    else
      redirect_to listings_path, alert: "Only the host can manage this listing."
    end
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
