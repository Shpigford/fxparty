class SyncTokenWorker
  include Sidekiq::Worker

  def perform(token_id)
    token = Token.find_or_create_by(fxid: token_id)

    fx_token = HTTParty.post("https://api.fxhash.xyz/graphql", :body => '{"operationName":"Query","variables":{"id":' + token_id.to_s + '},"query":"query Query($id: Float!) {generativeToken(id: $id) {id name price supply balance royalties createdAt metadata __typename marketStats {floor median highestSold lowestSold totalListing primTotal secVolumeTz secVolumeNb secVolumeTz24 secVolumeNb24 __typename} author {id name avatarUri __typename}}}"}',
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
      token.author_name = fx_token_obj['author']['name'].strip if fx_token_obj['author']['name'].present?
      token.author_address = fx_token_obj['author']['id']
      token.author_avatar = fx_token_obj['author']['avatarUri']
      token.created_at = fx_token_obj['createdAt'].to_datetime

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

      if token.sec_volume_tz_24.to_i > 0
        token.avg_price_24h = token.sec_volume_tz_24.to_f / token.sec_volume_nb_24.to_f
      end

      token.delisted = false

      if token.stats.where(metric: 'floor').where("DATE(captured_at) = ?", Date.today-1).order(captured_at: :asc).present?
        captured_at = DateTime.now

        current_floor = token.floor.to_f
        yesterday_floor = token.stats.where(metric: 'floor').where("DATE(captured_at) = ?", Date.today-1).order(captured_at: :asc).last.value.to_f
        raw_floor_change = (((yesterday_floor - current_floor) / ((yesterday_floor + current_floor)/2)) * 100).abs
        if raw_floor_change.nan?
          floor_change = 0.0
        else
          floor_change = current_floor < yesterday_floor ? -raw_floor_change : raw_floor_change
        end
        
        token.floor_change_24h = floor_change.to_f
      else
        token.floor_change_24h = 0
      end

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
        { token_id: token.id, metric: 'sec_volume_nb_24', value: token.sec_volume_nb_24, captured_at: captured_at },
        { token_id: token.id, metric: 'avg_price_24h', value: token.avg_price_24h.to_f, captured_at: captured_at },
        { token_id: token.id, metric: 'floor_change_24h', value: token.floor_change_24h, captured_at: captured_at }
      ])

      ProcessAvgSecWorker.perform_async(token.fxid)
    end
      
    token.save
  end
end
