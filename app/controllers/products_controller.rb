class ProductsController < ApplicationController
  def index
    @categories = Category.all
    @products = Product.all
    @products = @products.on_sale if params[:filter] == "sale"
    @products = @products.newly_added if params[:filter] == "new"
    @products = @products.by_category(params[:category]) if params[:category].present?
    @products = @products.where(category_id: params[:category]) if params[:category].present?
    @products = @products.where("name LIKE ? OR description LIKE ?", "%#{params[:search]}%",
                                         "%#{params[:search]}%") if params[:search].present?
    @products = @products.page(params[:products_page]).per(25)
    @pagination_params = { filter: params[:filter], category: params[:category], search: params[:search] }
  end

  def show
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: "Product not found."
  end

  def add_to_cart
    session[:cart] ||= []
    session[:cart] << params[:id]
    redirect_to products_path
  end
end
