class NeighborhoodsController < ApplicationController
  before_action :set_neighborhood, only: %i[show edit update destroy]

  def index
    @neighborhoods = Neighborhood.order(:city, :name)
  end

  def show
    @properties = @neighborhood.properties.order(:title)
  end

  def new
    @neighborhood = Neighborhood.new
  end

  def create
    @neighborhood = Neighborhood.new(neighborhood_params)

    if @neighborhood.save
      redirect_to @neighborhood, notice: "Neighborhood created."
    else
      flash.now[:alert] = "Could not create the neighborhood."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @neighborhood.update(neighborhood_params)
      redirect_to @neighborhood, notice: "Neighborhood updated."
    else
      flash.now[:alert] = "Could not update the neighborhood."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @neighborhood.destroy
      redirect_to neighborhoods_path, notice: "Neighborhood deleted."
    else
      redirect_to @neighborhood,
                  alert: @neighborhood.errors.full_messages.to_sentence
    end
  end

  private

  def set_neighborhood
    @neighborhood = Neighborhood.find(params[:id])
  end

  def neighborhood_params
    params.require(:neighborhood).permit(:name, :city)
  end
end
