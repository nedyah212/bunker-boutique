class UsersController < ApplicationController
  before_action :set_user, only: [:show, :create_address, :update_address, :delete_address]

  def show
    @address = @user.addresses.first || @user.addresses.build
    @addresses = @user.addresses
  end

  def create_address
    @user.update(user_params) if params[:first_name].present? || params[:last_name].present?

    @address = @user.addresses.build(address_params)
    if @address.save
      redirect_to @user, notice: "Address and profile updated successfully!"
    else
      redirect_to @user, alert: "Could not save address."
    end
  end

  def update_address
    @user.update(user_params) if params[:first_name].present? || params[:last_name].present?

    @address = @user.addresses.find(params[:address_id])
    if @address.update(address_params)
      redirect_to @user, notice: "Address and profile updated successfully!"
    else
      redirect_to @user, alert: "Could not update address."
    end
  end

  def delete_address
    @address = @user.addresses.find(params[:address_id])
    @address.destroy
    redirect_to @user, notice: "Address deleted successfully!"
  end

  private

  def set_user
    @user = User.find(params[:user_id] || params[:id])
  end

  def address_params
    params.require(:address).permit(:street, :city, :postal_code, :province_id)
  end

  def user_params
    params.permit(:first_name, :last_name)
  end
end