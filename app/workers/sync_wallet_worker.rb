class SyncWalletWorker
  include Sidekiq::Worker

  def perform(wallet_address)
    return unless wallet_address.present?
    
    wallet = Wallet.find_or_create_by(address: wallet_address)

    account_check = HTTParty.post("https://api.fxhash.xyz/graphql", :body => '{"operationName":"Query","variables":{"id":"' + wallet_address + '","skip":0,"take":1},"query":"query Query($id: String!, $take: Int, $skip: Int) {user(id: $id) {id objkts(take: $take, skip: $skip) {id assigned iteration owner {id name avatarUri __typename} issuer {id name flag author {id name avatarUri __typename} __typename} name metadata createdAt updatedAt offer {id price issuer {id name avatarUri __typename} __typename} __typename} __typename}}"}',
    :headers => {'Content-Type' => 'application/json'} ).body
    account_check_data = JSON.parse(account_check)

    if account_check_data['data']['user'] == nil
      wallet.update(status: 'not_found')
    else

      more_events = true
      offset = 0
      current_nfts = []

      until more_events === false do
        Rails.logger.warn("OFFSET: #{offset}")
        fx_assets = HTTParty.post("https://api.fxhash.xyz/graphql", :body => '{"operationName":"Query","variables":{"id":"' + wallet_address + '","skip":'+offset.to_s+',"take":50},"query":"query Query($id: String!, $take: Int, $skip: Int) {user(id: $id) {id objkts(take: $take, skip: $skip) {id assigned iteration owner {id name avatarUri __typename} issuer {id name flag author {id name avatarUri __typename} __typename} name metadata actions {type metadata createdAt __typename} createdAt updatedAt offer {id price issuer {id name avatarUri __typename} __typename} __typename} __typename}}"}',
        :headers => {'Content-Type' => 'application/json'},
        :timeout => 10).body
        fx_assets_data = JSON.parse(fx_assets)

        fx_tokens = fx_assets_data['data']['user']['objkts']

        if fx_tokens.blank?
          more_events = false
        else
          fx_tokens.each do |token|
            fx_asset = token
            token = Token.find_by(fxid: fx_asset['issuer']['id'])

            asset = Item.find_or_create_by(fxid: fx_asset["id"], token: token)
            
            asset.wallet = wallet
            asset.name = fx_asset['name']
            asset.token_fxid = fx_asset['issuer']['id']
            asset.image_url = fx_asset['metadata']['displayUri'] if fx_asset['metadata']['displayUri'].present?


            #######################################################################
            # Purchase price
            #######################################################################
            price_found = false
            fx_asset['actions'].each do |action|
              if (action['type'] == 'MINTED_FROM' or action['type'] == 'OFFER_ACCEPTED') and price_found == false
                asset.last_purchase_price_tz = action['metadata']['price'].to_i
                asset.last_purchase_at = action['createdAt'].to_datetime
                price_found = true
              end
            end

            #######################################################################
            # Current offer
            #######################################################################
            if fx_asset['offer'].present?
              asset.offer_price = fx_asset['offer']['price']
            else
              asset.offer_price = nil
            end
            

            asset.save
            current_nfts.push(asset.id)
            
            wallet.update(status: 'synced', last_updated_at: Time.now)
          end
          
          offset += 50
        end
      end

      #######################################################################
      # Find NFTs that are no longer in collection and remove them
      #######################################################################
      removed_nfts = Item.where(wallet_id: wallet.id).where.not(id: current_nfts)
      removed_nfts.delete_all
    
      #######################################################################
      # Stats
      #######################################################################
      SyncWalletStatsWorker.set(queue: :slow).perform_async(wallet_address)
      
    end
  end
end
