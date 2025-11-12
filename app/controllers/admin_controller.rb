class AdminController < ApplicationController
  before_action :authenticate_user!       # Make sure user is signed in
  before_action :require_admin            # Restrict access to admins only

  def dashboard
    # You can add instance variables here to show stats, orders, users, etc.
  end

  private

  def require_admin
    unless current_user.admin?
      flash[:alert] = "Access denied."
      redirect_to root_path
    end
  end
end