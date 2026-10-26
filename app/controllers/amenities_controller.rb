class AmenitiesController < ApplicationController
  before_action :set_amenity, only: %i[show edit update destroy]

  def index
    @amenities = Amenity.order(:category, :name)
  end

  def show
    @properties = @amenity.properties.order(:title)
  end

  def new
    @amenity = Amenity.new
  end

  def create
    @amenity = Amenity.new(amenity_params)

    if @amenity.save
      redirect_to @amenity, notice: "Amenity created."
    else
      flash.now[:alert] = "Could not create the amenity."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @amenity.update(amenity_params)
      redirect_to @amenity, notice: "Amenity updated."
    else
      flash.now[:alert] = "Could not update the amenity."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @amenity.destroy
      redirect_to amenities_path, notice: "Amenity deleted."
    else
      redirect_to @amenity, alert: @amenity.errors.full_messages.to_sentence
    end
  end

  private

  def set_amenity
    @amenity = Amenity.find(params[:id])
  end

  def amenity_params
    params.require(:amenity).permit(:name, :category)
  end
end
