<<<<<<< HEAD
class ListingsController < ApplicationController
  before_action :set_listing, only: :show
  before_action :set_owned_listing, only: %i[edit update destroy publish withdraw mark_rented]
  before_action :load_properties, only: %i[new create edit update]

  def index
    @listings = Listing.published.with_attached_photos
                       .includes(property: :neighborhood).order(:available_from)
  end

  def show
    @property = @listing.property
    @amenities = @property.amenities
    @reviews = @property.reviews.includes(:reviewer)
    @application = @listing.applications.find_by(applicant_id: current_user&.id)
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
    if @listing.update(listing_params)
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
      redirect_to listings_path, notice: "Listing deleted."
    else
      redirect_to @listing, alert: @listing.errors.full_messages.to_sentence
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
    return if !@listing.draft? || @listing.property.owner_id == current_user&.id

    raise ActiveRecord::RecordNotFound
  end

  def set_owned_listing
    @listing = Listing.joins(:property)
                      .where(properties: { owner_id: current_user.id })
                      .find(params[:id])
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

  def listing_params
    params.require(:listing).permit(
      :title, :monthly_rent, :deposit, :available_from,
      :minimum_stay, :furnished, :private_bathroom,
      :description, :house_rules, photos: []
    )
  end
end
=======
class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]

  def index
    @listings = Listing.all
  end

  def show
    @property = @listing.property
    @amenities = @property.amenities
    @reviews = @property.reviews.includes(:reviewer)
  end

  def new
    @listing = Listing.new(property_id: params[:property_id])
  end

  def create
    @listing = Listing.new(listing_params)
    if @listing.save
      redirect_to @listing, notice: "Listing was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @property = @listing.property
  end

  def update
    if @listing.update(listing_params)
      redirect_to @listing, notice: "Listing was successfully updated."
    else
      @property = @listing.property
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @listing = Listing.find(params[:id])
    @listing.destroy

    respond_to do |format|
      format.html { redirect_to listings_path, status: :see_other, notice: "El listing fue eliminado exitosamente." }
      format.json { head :no_content }
    end
  end
  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def listing_params
    params.require(:listing).permit(
      :title, :monthly_rent, :available_from, :deposit, 
      :minimum_stay, :furnished, :private_bathroom, 
      :description, :house_rules, :status, :property_id, photos: []
    )
  end
  
end
>>>>>>> f85dde4 (Assignment 4)
