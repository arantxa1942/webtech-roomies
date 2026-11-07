class ReportsController < ApplicationController
  before_action :set_listing, only: %i[new create]
  before_action :set_report, only: :resolve

  def index
    authorize Report
    @reports = policy_scope(Report).includes(:listing, :reporter, :moderator).order(created_at: :desc)
  end

  def new
    @report = @listing.reports.build
    authorize @report
  end

  def create
    @report = @listing.reports.build(report_params)
    @report.reporter = current_user
    authorize @report

    if @report.save
      redirect_to @listing, notice: "Thank you. A moderator will review your report."
    else
      flash.now[:alert] = "Could not send the report."
      render :new, status: :unprocessable_entity
    end
  end

  def resolve
    @report.resolve!(
      moderator: current_user,
      status: params.dig(:report, :status),
      notes: params.dig(:report, :moderator_notes)
    )
    redirect_to reports_path, notice: "Report marked as #{@report.status}."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to reports_path, alert: e.record.errors.full_messages.to_sentence
  end

  private

  def set_listing
    @listing = policy_scope(Listing).find(params[:listing_id])
  end

  def set_report
    @report = policy_scope(Report).find(params[:id])
    authorize @report
  end

  def report_params
    params.require(:report).permit(:reason)
  end
end