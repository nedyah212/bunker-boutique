module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    def index
      @products = Product.all
      @categories = Category.all
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