class CartsController < ApplicationController
  def index
    @cart = session[:cart] || {}
    @products = Product.where(id: @cart.keys)
  end
end