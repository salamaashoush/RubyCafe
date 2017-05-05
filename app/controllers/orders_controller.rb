class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.includes([:orders_products,:products]).all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    order_details = order_params
    order_products_list = order_details[:product_ids].reject{|p| p.empty?}
    order_details.delete(:product_ids)
    ActiveRecord::Base.transaction do
      @order = Order.create!(order_details)
      order_products = []
      order_products_list.each do |product_id|
        order_products.push({:amount=>1,:order_id=>@order.id,:product_id=>product_id})
      end
      OrdersProduct.create!(order_products)
    end
    respond_to do |format|
      format.html { redirect_to @order, notice: 'Order was successfully created.' }
      format.json { render :show, status: :created, location: @order }
    end
  rescue Exception => ex
    respond_to do |format|
      format.html { render :new }
      format.json { render json: @order.errors, status: :unprocessable_entity }
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:status, :note, :user_id, :room_id, :product_ids=>[])
  end
end