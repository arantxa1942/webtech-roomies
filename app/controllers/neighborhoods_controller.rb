class NeighborhoodsController < ApplicationController
    def index
        @neighborhoods = Neighborhood.order(:city, :name)
    end

    def show
        @neighborhood = Neighborhood.find(params[:id])
        @properties = @neighborhood.properties.order(:title)
    end
end