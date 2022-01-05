class SyncTokensWorker
  include Sidekiq::Worker

  def perform
    tzkt_token = HTTParty.get("https://api.tzkt.io/v1/bigmaps/70072/keys?sort.desc=id&select=value%2Ckey&limit=1").body
    tzkt_token = JSON.parse(tzkt_token)
    total_tokens = tzkt_token.first['key']

    (0..total_tokens).each do |n|
      SyncTokenWorker.perform_async(n)
    end
  end
end
