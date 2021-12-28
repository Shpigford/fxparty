namespace :maintenance do
  desc "Update tokens"
  task :update_tokens => :environment do
    SyncTokensWorker.perform_async
  end

  desc "Update wallets"
  task :update_wallets => :environment do
    # Only process a set % of oldest updated wallets
    total_wallets = Wallet.active.count
    limit = (0.25 * total_wallets).ceil
    wallets = Wallet.active.order('last_updated_at ASC NULLS FIRST').limit(limit)

    wallets.each do |wallet|
      SyncWalletWorker.perform_async(wallet.address)
    end
  end
end