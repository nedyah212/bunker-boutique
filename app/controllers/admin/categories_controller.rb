module Admin
  class CategoriesController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin
    before_action :set_category, only: [:edit, :update, :destroy]

    def index
      @categories = Category.all
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)
      if @category.save
        redirect_to admin_dashboard_path, notice: "Category created successfully."
      else
        flash.now[:alert] = "Failed to create category."
        render :new
      end
    end

    def edit
    end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "Category updated successfully."
      else
        flash.now[:alert] = "Failed to update category."
        render :edit
      end
    end

    def destroy
      @category = Category.find(params[:id])
      @category.destroy
      redirect_to admin_dashboard_path, notice: "Category deleted successfully."
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :description)
    end

    def require_admin
      unless current_user.admin?
        flash[:alert] = "Access denied."
        redirect_to root_path
      end
    end
  end
end
