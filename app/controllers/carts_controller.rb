class CartsController < ApplicationController
  def index
    product_ids = session[:cart] || []
    @products = Product.where(id: product_ids)
    end
  end
end