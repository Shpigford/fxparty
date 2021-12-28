class WalletsController < ApplicationController
  def show
    @wallet = Wallet.find_or_create_by(address: params[:id])

    if @wallet.status == 'synced'
      @items = @wallet.items.includes(:token).order(last_purchase_price_tz: :desc)
      @floor_value = @items.sum('tokens.floor')
      @cost_basis = @items.sum(:last_purchase_price_tz) / 1000000
      @unrealized = @floor_value - @cost_basis
      @wallet.touch(:last_viewed_at)
    elsif @wallet.status != 'not_found'
      SyncWalletWorker.perform_async(@wallet.address)
      
      @wallet.status = 'syncing'
      @wallet.save
    end
  end
end
