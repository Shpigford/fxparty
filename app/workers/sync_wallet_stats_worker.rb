class SyncWalletStatsWorker
  include Sidekiq::Worker

  def perform(wallet_address)
    return unless wallet_address.present?
    
    wallet = Wallet.find_or_create_by(address: wallet_address)

    items = wallet.items.includes(:token)

    wallet.stat_floor_value = items.sum('tokens.floor')
    wallet.stat_sec_avg_recent = items.sum('tokens.sec_avg_recent')
    wallet.stat_floor_royalties = items.sum('tokens.floor_royalties')
    wallet.stat_potential_royalties = items.sum('tokens.potential_royalties')
    wallet.stat_cost_basis = items.sum(:last_purchase_price_tz)
    wallet.stat_unrealized_gains = wallet.stat_sec_avg_recent - wallet.stat_potential_royalties - items.sum(:last_purchase_price_tz)
    wallet.stat_size = items.count
    wallet.save
  end
end
