class ReviewsController < ApplicationController
  before_action :set_property
  before_action :set_review, only: %i[edit update destroy]
  before_action :authorize_reviewer!, only: %i[edit update destroy]

  def new
    @visit = completed_visits.find(params[:visit_id])
    @review = @property.reviews.build(
      visit: @visit,
      reviewer: current_user
    )
  rescue ActiveRecord::RecordNotFound
    redirect_to @property,
                alert: "You can only review your own completed visits."
  end

  def create
    @visit = completed_visits.find(params[:visit_id])
    @review = @property.reviews.build(review_params)
    @review.visit = @visit
    @review.reviewer = current_user

    if @review.save
      redirect_to @property, notice: "Review submitted."
    else
      flash.now[:alert] = "Could not submit the review."
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to @property,
                alert: "You can only review your own completed visits."
  end

  def edit
    @visit = @review.visit
  end

  def update
    @visit = @review.visit

    if @review.update(review_params)
      redirect_to @property, notice: "Review updated."
    else
      flash.now[:alert] = "Could not update the review."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @review.destroy
      redirect_to @property, notice: "Review deleted."
    else
      redirect_to @property,
                  alert: @review.errors.full_messages.to_sentence
    end
  end

  private

  def set_property
    @property = Property.find(params[:property_id])
  end

  def set_review
    @review = @property.reviews.find(params[:id])
  end

  def authorize_reviewer!
    return if @review.reviewer_id == current_user&.id

    redirect_to @property,
                alert: "You are not allowed to manage this review."
  end

  def completed_visits
    Visit.joins(application: { listing: :property })
         .where(
           applications: { applicant_id: current_user.id },
           properties: { id: @property.id },
           status: :completed
         )
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end