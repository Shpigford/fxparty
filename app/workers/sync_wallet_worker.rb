class SyncWalletWorker
  include Sidekiq::Worker

  def perform(wallet_address)
    wallet = Wallet.find_or_create_by(address: wallet_address)

    account_check = HTTParty.post("https://api.fxhash.xyz/graphql", :body => '{"operationName":"Query","variables":{"id":"' + wallet_address + '","skip":0,"take":1},"query":"query Query($id: String!, $take: Int, $skip: Int) {\n  user(id: $id) {\n    id\n    objkts(take: $take, skip: $skip) {\n      id\n      assigned\n      iteration\n      owner {\n        id\n        name\n        avatarUri\n        __typename\n      }\n      issuer {\n        id\n        name\n        flag\n        author {\n          id\n          name\n          avatarUri\n          __typename\n        }\n        __typename\n      }\n      name\n      metadata\n  createdAt\n      updatedAt\n      offer {\n        id\n        price\n        issuer {\n          id\n          name\n          avatarUri\n          __typename\n        }\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n}\n"}',
    :headers => {'Content-Type' => 'application/json'} ).body
    account_check_data = JSON.parse(account_check)

    if account_check_data['data']['user'] == nil
      wallet.update(status: 'not_found')
    else

      more_events = true
      offset = 0

      until more_events === false do
        Rails.logger.warn("OFFSET: #{offset}")
        fx_assets = HTTParty.post("https://api.fxhash.xyz/graphql", :body => '{"operationName":"Query","variables":{"id":"' + wallet_address + '","skip":'+offset.to_s+',"take":50},"query":"query Query($id: String!, $take: Int, $skip: Int) {\n  user(id: $id) {\n    id\n    objkts(take: $take, skip: $skip) {\n      id\n      assigned\n      iteration\n      owner {\n        id\n        name\n        avatarUri\n        __typename\n      }\n      issuer {\n        id\n        name\n        flag\n        author {\n          id\n          name\n          avatarUri\n          __typename\n        }\n        __typename\n      }\n      name\n      metadata\n      actions\n {\n type\n metadata\n createdAt\n  __typename\n}  createdAt\n      updatedAt\n      offer {\n        id\n        price\n        issuer {\n          id\n          name\n          avatarUri\n          __typename\n        }\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n}\n"}',
        :headers => {'Content-Type' => 'application/json'} ).body
        fx_assets_data = JSON.parse(fx_assets)

        fx_tokens = fx_assets_data['data']['user']['objkts']

        if fx_tokens.blank?
          more_events = false
        else
          fx_tokens.each do |token|
            fx_asset = token
            token = Token.find_by(fxid: fx_asset['issuer']['id'])

            asset = Item.find_or_create_by(fxid: fx_asset["id"], wallet: wallet, token: token)

            asset.name = fx_asset['name']
            asset.token_fxid = fx_asset['issuer']['id']
            asset.image_url = fx_asset['metadata']['displayUri'] if fx_asset['metadata']['displayUri'].present?

            price_found = false
            fx_asset['actions'].each do |action|
              if (action['type'] == 'MINTED_FROM' or action['type'] == 'OFFER_ACCEPTED') and price_found == false
                asset.last_purchase_price_tz = action['metadata']['price'].to_i
                price_found = true
              end
            end

            asset.save
          
            wallet.update(status: 'synced')
          end
          
          offset += 50
        end
      end
    
    end
  end
end
