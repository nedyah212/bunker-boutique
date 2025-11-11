class ProductsController < ApplicationController
  def index
    @products = Product.all
    @products = @products.on_sale if params[:filter] == "sale"
    @products = @products.newly_added if params[:filter] == "new"
  end

  def show
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: "Product not found."
  end
end
