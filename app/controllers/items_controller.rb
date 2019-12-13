class ItemsController < ApplicationController
  before_action :set_item, only: [:edit, :show]

  def index
    @items = Item.all
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
    item = Item.find(params[:id])

  end  

  def edit
  end  

  def show
  end

  

  private

  def item_params
    params.require(:item).permit(
      :name, :size, :status, :derivery_fee, :derivery_method,
      :price, :derivery_estimated, :description, :image, :category_id, :brand_id, :prefecture_id)
  end  

  def set_item
    @item = Item.find(params[:id])
  end

end