class SyncTokenWorker
  include Sidekiq::Worker

  def perform(token_id)
    token = Token.find_or_create_by(fxid: token_id)

    fx_token = HTTParty.post("https://api.fxhash.xyz/graphql", :body => '{"operationName":"Query","variables":{"id":' + token_id.to_s + '},"query":"query Query($id: Float!) {generativeToken(id: $id) {id name price supply balance royalties metadata __typename marketStats {floor median highestSold lowestSold totalListing primTotal secVolumeTz secVolumeNb secVolumeTz24 secVolumeNb24 __typename} author {id name avatarUri __typename}}}"}',
    :headers => {'Content-Type' => 'application/json'} ).body
    fx_token_data = JSON.parse(fx_token)
    fx_token_obj = fx_token_data['data']['generativeToken']

    if fx_token_obj.blank?
      token.delisted = true
    else
      token.name = fx_token_obj['name'].strip
      token.supply = fx_token_obj['supply']
      token.balance = fx_token_obj['balance']
      token.mint_progress = ((fx_token_obj['supply'] - fx_token_obj['balance']).to_f / fx_token_obj['supply'].to_f) * 100 
      token.royalties = fx_token_obj['royalties']
      token.author_name = fx_token_obj['author']['name'].strip
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

      token.delisted = false

      captured_at = DateTime.now

      Stat.insert_all([
        { token_id: token.id, metric: 'floor', value: token.floor, captured_at: captured_at },
        { token_id: token.id, metric: 'median', value: token.median, captured_at: captured_at },
        { token_id: token.id, metric: 'total_listing', value: token.total_listing, captured_at: captured_at },
        { token_id: token.id, metric: 'highest_sold', value: token.highest_sold, captured_at: captured_at },
        { token_id: token.id, metric: 'lowest_sold', value: token.lowest_sold, captured_at: captured_at },
        { token_id: token.id, metric: 'prim_total', value: token.prim_total, captured_at: captured_at },
        { token_id: token.id, metric: 'sec_volume_tz', value: token.sec_volume_tz, captured_at: captured_at },
        { token_id: token.id, metric: 'sec_volume_nb', value: token.sec_volume_nb, captured_at: captured_at },
        { token_id: token.id, metric: 'sec_volume_tz_24', value: token.sec_volume_tz_24, captured_at: captured_at },
        { token_id: token.id, metric: 'sec_volume_nb_24', value: token.sec_volume_nb_24, captured_at: captured_at }
      ])
    end
      
    token.save
  end
end
