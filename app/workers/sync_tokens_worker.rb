class SyncTokensWorker
  include Sidekiq::Worker

  sidekiq_options queue: :critical, lock: :while_executing, on_conflict: :reject

  def perform
    tzkt_token = HTTParty.get("https://api.tzkt.io/v1/bigmaps/70072/keys?sort.desc=id&select=value%2Ckey&limit=1").body
    tzkt_token = JSON.parse(tzkt_token)
    total_tokens = tzkt_token.first['key'].to_i

      (total_tokens).downto(0).each do |n|
      SyncTokenWorker.perform_async(n)
    end
  end
end
