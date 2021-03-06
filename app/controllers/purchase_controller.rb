class PurchaseController < ApplicationController
  before_action :set_credit, :set_item

  def show
    if @item.user_id != current_user.id
      if @item.buyer_id.blank?
        if @credit.present?
          Payjp.api_key = Rails.application.credentials.payjp_secret_key
          customer = Payjp::Customer.retrieve(@credit.customer_id)
          # 取得した顧客がもつカードのうち、DB内のcard_idと紐付くものを取得
          # カード情報を表示させるために代入
          @credit_information = customer.cards.retrieve(@credit.card_id)
          # カード会社のロゴ
          @credit_brand = @credit_information.brand
        end
      else
        redirect_to root_path
        return
      end
    else
      redirect_to root_path
      return
    end
  end

  def pay
    Payjp.api_key = Rails.application.credentials.payjp_secret_key
    if current_user.id != @item.user_id && @item.buyer_id == nil
      Payjp::Charge.create(
        amount: @item.price,             # 金額
        customer: @credit.customer_id,   # 顧客情報
        currency: 'jpy'                  # 通貨
      )
      @item.buyer_id = current_user.id
      @item.save
      redirect_to done_item_purchase_path # 完了画面へ移動
    else
      redirect_to root_path, alert: "Error"
    end
  end

  def done
  end

  private

  def item_params
    params.require(:item).permit(
    :name, :size, :status, :derivery_fee, :derivery_method,
    :price, :derivery_estimated, :description, :image, :category1, :category2, :category3, :brand, :prefecture_id, :buyer_id).merge(user_id: current_user.id)
  end
    
  #user_idがcurrent_userになるレコードを代入
  def set_credit
    @credit = Credit.find_by(user_id: current_user.id)
  end

  # idがparams[:id]なレコードを代入
  def set_item
    @item = Item.find(params[:id])
  end
end
