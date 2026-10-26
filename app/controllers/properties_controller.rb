class PropertiesController < ApplicationController
  before_action :set_property, only: [:show, :edit, :update, :destroy]

  def index
    @properties = Property.all
  end

def show
    @property = Property.find(params[:id])
    @listings = @property.listings
    @reviewable_visits =
      if current_user.present?
        Visit.joins(application: { listing: :property })
            .left_outer_joins(:review)
            .where(
              applications: { applicant_id: current_user.id },
              properties: { id: @property.id },
              status: :completed,
              reviews: { id: nil }
            )
      else
        Visit.none
      end
    @reviews = @property.reviews # Agregamos esta línea para definir las reseñas
  end

  def new
    @property = Property.new
  end

  def create
    @property = current_user.properties.build(property_params)

    if @property.save
      redirect_to @property, notice: 'Propiedad creada exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @property.update(property_params)
      redirect_to @property, notice: 'Propiedad actualizada exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @property.destroy
    redirect_to properties_path, notice: 'Propiedad eliminada correctamente.'
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end
  def property_params
    params.require(:property).permit(
      :title, :address, :neighborhood_id, :property_type,
      :bedrooms, :bathrooms, :shared_spaces, amenity_ids: []
    )
  end
end