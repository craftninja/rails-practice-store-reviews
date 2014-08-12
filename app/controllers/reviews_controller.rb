class ReviewsController < ApplicationController

  def create
    @review = Review.new(params.require(:review).permit(:description, :stars).merge(user_id: session[:id], product_id: params[:product_id]))
    if @review.save
      redirect_to product_path(params[:product_id])
    else
      @product = Product.find(params[:product_id])
      @cart_item = CartItem.all
      render template: 'products/show'
    end
  end

end
