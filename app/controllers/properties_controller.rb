class PropertiesController < ApplicationController
  before_action :set_property, only: %i[show edit update destroy]
  before_action :require_owner!, only: %i[edit update destroy]

  def index
    @properties = Property.includes(:neighborhood).order(:title)
  end

  def show
    @listings = @property.listings
    @reviews = @property.reviews.includes(:reviewer)
    @reviewable_visits =
      Visit.joins(application: { listing: :property })
           .left_outer_joins(:review)
           .where(applications: { applicant_id: current_user.id },
                  properties: { id: @property.id },
                  status: :completed,
                  reviews: { id: nil })
  end

  def new
    @property = Property.new
  end

  def create
    @property = current_user.properties.build(property_params)

    if @property.save
      redirect_to @property, notice: "Property created."
    else
      flash.now[:alert] = "Could not create the property."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @property.update(property_params)
      redirect_to @property, notice: "Property updated."
    else
      flash.now[:alert] = "Could not update the property."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @property.destroy
      redirect_to properties_path, notice: "Property deleted."
    else
      redirect_to @property, alert: @property.errors.full_messages.to_sentence
    end
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end

  def require_owner!
    return if @property.owner_id == current_user.id
    redirect_to @property, alert: "Only the host can modify this property."
  end

  def property_params
    params.require(:property).permit(
      :title, :address, :neighborhood_id, :property_type,
      :bedrooms, :bathrooms, :shared_spaces, amenity_ids: []
    )
  end
end
