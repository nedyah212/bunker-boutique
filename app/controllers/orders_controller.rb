class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  def new
    @order = Order.new
    @cart_items = get_cart_items
    @address = current_user.addresses.first
    @provinces = Province.all

    if @cart_items.empty?
      redirect_to products_path, alert: "Your cart is empty."
      return
    end

    if current_user.addresses.empty?
      redirect_to user_path(current_user), alert: "Please add a shipping address before checking out."
      return
    end

    calculate_totals
  end

  def create
    @order = current_user.orders.build
    @cart_items = get_cart_items

    if @cart_items.empty?
      redirect_to products_path, alert: "Your cart is empty."
      return
    end

    # Require address selection
    if params[:address_id].blank?
      @provinces = Province.all
      @address = current_user.addresses.first
      calculate_totals
      flash.now[:alert] = "Please select a shipping address."
      render :new
      return
    end

    @order.address_id = params[:address_id]

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
      @address = current_user.addresses.first
      calculate_totals
      flash.now[:alert] = "Unable to create order: #{@order.errors.full_messages.join(', ')}"
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

    # Use user's first address province for tax calculation
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
end