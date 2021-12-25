namespace :maintenance do
  desc "Update tokens"
  task :update_tokens => :environment do
    SyncTokensWorker.perform_async
  end

  desc "Update wallets"
  task :update_wallets => :environment do
    Wallet.where(status: 'synced').each do |wallet|
      SyncWalletWorker.perform_async(wallet.address)
    end
  end
end