namespace :maintenance do
  desc "Update tokens"
  task :update_tokens => :environment do
    # Only process a set % of oldest updated tokens
    total_tokens = Token.active.count
    limit = (0.25 * total_tokens).ceil
    tokens = Token.active.order('updated_at ASC NULLS FIRST').limit(limit)

    tokens.each do |token|
      SyncTokenWorker.perform_async(token.fxid)
    end
  end

  desc "Get new tokens"
  task :new_tokens => :environment do
    GetNewTokensWorker.perform_async
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

  desc "Update top wallets"
  task :update_top_wallets => :environment do
    wallets = Wallet.active.tracked

    wallets.each do |wallet|
      SyncWalletWorker.set(queue: :critical).perform_async(wallet.address)
    end
  end

  desc "Mass wallet import"
  task :wallet_import => :environment do
    updates = HTTParty.get("https://api.tzkt.io/v1/bigmaps/updates?contract=KT1KEa8z6vWXDJrVqtMrAeDVzsvxat3kHaCE&sort.asc=id&limit=10000&bigmap=22785").body
    transactions = JSON.parse(updates)

    addresses = []

    transactions.each do |transaction|
      addresses.push(transaction['content']['key']['address']) if transaction['content'].present? and transaction['content']['key']['address'].present?  
    end

    addresses = addresses.uniq

    existing_addresses = Wallet.where(address: addresses).pluck(:address)
    missing_addresses = (addresses - existing_addresses).uniq

      missing_addresses.each do |address|
      SyncWalletWorker.perform_async(address) 
    end
  end
end