module Admin
  class ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin
    before_action :set_product, only: [:edit, :update, :destroy]

    def index
      @products = Product.all
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: "Product created successfully."
      else
        flash.now[:alert] = "Failed to create product."
        render :new
      end
    end

    def edit
    end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: "Product updated successfully."
      else
        flash.now[:alert] = "Failed to update product."
        render :edit
      end
    end

    def destroy
      @product = Product.find(params[:id])
      @product.destroy
      redirect_to admin_dashboard_path, notice: "Product deleted successfully."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:category_id, :name, :description, :price, :quantity_in_stock, :on_sale, images: [])
    end

    def require_admin
      unless current_user.admin?
        flash[:alert] = "Access denied."
        redirect_to root_path
      end
    end
  end
end
