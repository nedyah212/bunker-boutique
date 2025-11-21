class CartsController < ApplicationController
  def index
    @product_ids = session[:cart] || []
  end
end