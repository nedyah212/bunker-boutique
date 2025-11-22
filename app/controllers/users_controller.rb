class UsersController < ApplicationController
  before_action :set_user, only: [:show, :create_address, :update_address, :delete_address]
  def show
    @address = @user.addresses.first || @user.addresses.build
    @addresses = @user.addresses
  end
  def create_address
    @address = @user.addresses.build(address_params)
    if @address.save
      redirect_to @user
    else
      redirect_to @user
    end
  end
  def update_address
    @address = @user.addresses.find(params[:address_id])
    if @address.update(address_params)
      redirect_to @user
    else
      redirect_to @user
    end
  end
  def delete_address
    @address = @user.addresses.find(params[:address_id])
    @address.destroy
    redirect_to @user
  end
  def set_user
    @user = User.find(params[:user_id] || params[:id])
  end
  def address_params
    params.require(:address).permit(:street, :city, :postal_code, :province_id)
  end
end