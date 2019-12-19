class ItemsController < ApplicationController
  require "payjp"
  before_action :set_item, only: [:edit, :show, :destroy, :pay, :purchase]
  before_action :move_to_index, except: [:index, :show]

  def index
    @items = Item.includes(:user)
  end

  def new
    @item = Item.new
  end
  
  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path
    else 
      render :new, notice: '保存できませんでした'
    end
  end


  def destroy
    if @item.destroy
      redirect_to root_path if user_signed_in? && current_user.id == @item.user_id
    else
      render :new, notice: "削除しました"
    end
  end  

  def edit

  end  

  def update

    
    if @item.update(item_params)
      redirect_to root_path if user_signed_in? && current_user.id == @item.user_id
    else  
      render :edit, notice: "編集しました"
    end
    

  end


  

  def show
  end

  def purchase
    @credit = Credit.find_by(user_id: current_user.id)
    if @credit.present?
      Payjp.api_key = "sk_test_4854d0c360476b8cab020092"
      customer = Payjp::Customer.retrieve(@credit.customer_id)
      @credit_information = customer.cards.retrieve(@credit.card_id)
      # 《＋α》 登録しているカード会社のブランドアイコンを表示するためのコードです。---------
      @credit_brand = @credit_information.brand
      case @credit_brand
      when "Visa"
        @credit_src = "visa.svg"
      when "JCB"
        @credit_src = "jcb.svg"
      when "MasterCard"
        @credit_src = "master-card.svg"
      when "American Express"
        @credit_src = "american_express.svg"
      when "Diners Club"
        @credit_src = "dinersclub.svg"
      when "Discover"
        @credit_src = "discover.svg"
      end
      # ---------------------------------------------------------------
    
    end
    
  end

  def pay
    Payjp.api_key = "sk_test_4854d0c360476b8cab020092"
    @credit = Credit.find_by(user_id: current_user.id)
    @credit.card_id = Payjp::Charge.create(
      amount: @item.price,
      customer: @credit.customer_id,
      card: params['payjp-token'],
      currency: 'jpy'
    )
    redirect_to done_items_path
  end

  def done
  end

  private

  def item_params
    params.require(:item).permit(
      :name, :size, :status, :derivery_fee, :derivery_method,
      :price, :derivery_estimated, :description, :image, :category1, :category2, :category3, :brand, :prefecture_id).merge(user_id: current_user.id)
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def move_to_index
    redirect_to action: :index unless user_signed_in?
  end

end