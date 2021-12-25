class WalletsController < ApplicationController
  def show
    @wallet = Wallet.find_or_create_by(address: params[:id])

    if @wallet.status == 'synced'
      @items = Item.where(wallet: @wallet.address).order(last_purchase_price_tz: :desc)
    elsif @wallet.status != 'not_found'
      SyncWalletWorker.perform_async(@wallet.address)
      
      @wallet.status = 'syncing'
      @wallet.save
    end
  end
end
