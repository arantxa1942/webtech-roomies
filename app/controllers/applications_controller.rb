class ApplicationsController < ApplicationController
    def index
        @applications = Application.includes(:listing, :applicant).order(created_at: :desc)
    end

    def show
        @application = Application.find(params[:id])
        @visit = @application.visit
    end
end
