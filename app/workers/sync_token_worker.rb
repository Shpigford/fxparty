class SyncTokenWorker
  include Sidekiq::Worker

  def perform(token_id)
    require 'open-uri'

    token = Token.find_or_create_by(fxid: token_id)

    unless token.delisted == true
      fx_token = HTTParty.post("https://api.fxhash.xyz/graphql", :body => '{"operationName":"Query","variables":{"id":' + token_id.to_s + '},"query":"query Query($id: Float!) {generativeToken(id: $id) {id name price supply balance royalties metadata __typename marketStats {floor median highestSold lowestSold totalListing primTotal secVolumeTz secVolumeNb secVolumeTz24 secVolumeNb24 __typename} author {id name avatarUri __typename}}}"}',
      :headers => {'Content-Type' => 'application/json'} ).body
      fx_token_data = JSON.parse(fx_token)
      fx_token_obj = fx_token_data['data']['generativeToken']

      if fx_token_obj.blank?
        token.delisted = true
      else
        token.name = fx_token_obj['name']
        token.supply = fx_token_obj['supply']
        token.balance = fx_token_obj['balance']
        token.royalties = fx_token_obj['royalties']
        token.author_name = fx_token_obj['author']['name']
        token.author_address = fx_token_obj['author']['id']
        token.author_avatar = fx_token_obj['author']['avatarUri']
        token.floor = fx_token_obj['marketStats']['floor']
        token.median = fx_token_obj['marketStats']['median']
        token.total_listing = fx_token_obj['marketStats']['totalListing']
        token.highest_sold = fx_token_obj['marketStats']['highestSold']
        token.lowest_sold = fx_token_obj['marketStats']['lowestSold']
        token.prim_total = fx_token_obj['marketStats']['primTotal']
        token.sec_volume_tz = fx_token_obj['marketStats']['secVolumeTz']
        token.sec_volume_nb = fx_token_obj['marketStats']['secVolumeNb']
        token.sec_volume_tz_24 = fx_token_obj['marketStats']['secVolumeTz24']
        token.sec_volume_nb_24 = fx_token_obj['marketStats']['secVolumeNb24']
      end
        
      token.save
    end
  end
end
