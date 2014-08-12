class ReviewsController < ApplicationController

  def create
    review = Review.new(params.require(:review).permit(:description, :stars).merge(user_id: session[:id], product_id: params[:product_id]))
    review.save
    redirect_to product_path(params[:product_id])
  end

end
