module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    def index
      @products = Product.page(params[:products_page]).per(12)
      @categories = Category.page(params[:categories_page]).per(10)
    end

    private

    def require_admin
      unless current_user.admin?
        flash[:alert] = "Access denied."
        redirect_to root_path
      end
    end
  end
end