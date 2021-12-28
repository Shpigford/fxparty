class SyncTokensWorker
  include Sidekiq::Worker

  def perform
    tzkt_token = HTTParty.get("https://api.tzkt.io/v1/bigmaps/22781").body
    tzkt_token = JSON.parse(tzkt_token)
    total_tokens = tzkt_token['totalKeys'] - 1

    (0..total_tokens).each do |n|
      SyncTokenWorker.perform_async(n)
    end
  end
end
