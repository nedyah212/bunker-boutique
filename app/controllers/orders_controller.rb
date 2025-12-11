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

    def process_payment
    @cart_items = get_cart_items

    if @cart_items.empty?
      redirect_to products_path, alert: "Your cart is empty."
      return
    end

    if params[:address_id].blank?
      redirect_to new_order_path
      return
    end

    address = current_user.addresses.find(params[:address_id])
    province = address.province

    # Calculate totals
    subtotal = @cart_items.sum { |product, quantity| product.price * quantity }
    tax_rate = calculate_tax_rate(province)
    tax_amount = (subtotal * tax_rate / 100.0).round
    total = subtotal + tax_amount

    begin
      # Create or retrieve Stripe customer
      if current_user.stripe_customer_id.blank?
        customer = Stripe::Customer.create({
          email: current_user.email,
          source: params[:stripeToken],
          description: "Customer for #{current_user.email}"
        })
        current_user.update(stripe_customer_id: customer.id)
      else
        # Update existing customer with new card
        customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
        customer.source = params[:stripeToken]
        customer.save
      end

      # Create charge using customer
      charge = Stripe::Charge.create({
        amount: total,
        currency: 'cad',
        customer: customer.id,
        description: "Order for #{current_user.email}"
      })

      @order = current_user.orders.build
      @order.address_id = params[:address_id]
      @order.stripe_customer_id = customer.id
      @order.stripe_payment_id = charge.id
      @order.status = "paid"
      @order.total_price = total
      @order.tax_amount = tax_amount

      if @order.save
        # Create order items
        @cart_items.each do |product, quantity|
          unit_tax = (product.price * tax_rate / 100.0).round
          @order.order_items.create!(
            product: product,
            quantity: quantity,
            unit_price: product.price,
            unit_tax: unit_tax
          )
        end

        session[:cart] = {}
        redirect_to order_path(@order), notice: "Payment successful, #{current_user.first_name}! Thank you for your order."
      else
        flash[:alert] = 'Order could not be saved'
        redirect_to new_order_path
      end

    rescue Stripe::CardError => e
      flash[:alert] = e.message
      redirect_to new_order_path
    rescue Stripe::StripeError => e
      flash[:alert] = "Payment error: #{e.message}"
      redirect_to new_order_path
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