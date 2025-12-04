class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  def new
    @order = Order.new
    @cart_items = get_cart_items
    @address = current_user.addresses.first || current_user.addresses.build
    @provinces = Province.all

    if @cart_items.empty?
      redirect_to products_path, alert: "Your cart is empty."
      return
    end

    calculate_totals
  end

  def create
    @order = current_user.orders.build(order_params)
    @cart_items = get_cart_items

    if @cart_items.empty?
      redirect_to products_path, alert: "Your cart is empty."
      return
    end

    # Handle address
    if params[:use_existing_address] == "true" && params[:address_id].present?
      @order.address_id = params[:address_id]
    else
      # Create new address
      address = current_user.addresses.build(address_params)
      if address.save
        @order.address = address
      else
        @provinces = Province.all
        calculate_totals
        flash.now[:alert] = "Please provide a valid address."
        render :new
        return
      end
    end

    # Calculate totals based on province
    province = @order.address.province
    calculate_order_totals(province)

    @order.status = "pending"

    if @order.save
      # Create order items
      @cart_items.each do |product, quantity|
        tax_rate = calculate_tax_rate(province)
        unit_tax = (product.price * tax_rate / 100.0).round

        @order.order_items.create!(
          product: product,
          quantity: quantity,
          unit_price: product.price,
          unit_tax: unit_tax
        )
      end

      # Clear the cart
      session[:cart] = {}

      redirect_to order_path(@order), notice: "Order placed successfully!"
    else
      @provinces = Province.all
      calculate_totals
      flash.now[:alert] = "Unable to create order."
      render :new
    end
  end

  def show
    @order = current_user.orders.find(params[:id])
    @order_items = @order.order_items.includes(:product)
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: "Order not found."
  end

  def index
    @orders = current_user.orders.order(created_at: :desc).page(params[:page]).per(10)
  end

  private

  def set_cart
    @cart = session[:cart] || {}
  end

  def get_cart_items
    return [] if @cart.empty?
    products = Product.where(id: @cart.keys)
    products.map { |product| [product, @cart[product.id.to_s].to_i] }
  end

  def calculate_totals
    @subtotal = 0
    @cart_items.each do |product, quantity|
      @subtotal += product.price * quantity
    end

    # Use user's address province if available, otherwise use a default for display
    province = current_user.addresses.first&.province || Province.find_by(code: "ON")
    tax_rate = calculate_tax_rate(province)

    @tax_amount = (@subtotal * tax_rate / 100.0).round
    @total = @subtotal + @tax_amount
    @province = province
  end

  def calculate_order_totals(province)
    subtotal = 0
    @cart_items.each do |product, quantity|
      subtotal += product.price * quantity
    end

    tax_rate = calculate_tax_rate(province)
    tax_amount = (subtotal * tax_rate / 100.0).round

    @order.total_price = subtotal + tax_amount
    @order.tax_amount = tax_amount
  end

  def calculate_tax_rate(province)
    if province.hst_rate > 0
      province.hst_rate
    else
      province.gst_rate + province.pst_rate
    end
  end

  def order_params
    params.require(:order).permit(:address_id)
  end

  def address_params
    params.require(:address).permit(:street, :city, :postal_code, :province_id)
  end
end
