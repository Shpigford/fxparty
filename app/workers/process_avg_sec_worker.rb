class ProcessAvgSecWorker
  include Sidekiq::Worker

  sidekiq_options queue: :slow, lock: :while_executing, on_conflict: :reject

  def perform(token_id)
    token = Token.find_or_create_by(fxid: token_id)

    transactions = HTTParty.post("https://api.fxhash.xyz/graphql", :body => '{"operationName":"Query","variables":{"id":' + token_id.to_s + ',"take":10, "filters":{"type_in": ["OFFER_ACCEPTED"]}},"query":"query Query($id: Float!, $take: Int, $filters: ActionFilter) {generativeToken(id: $id) {actions(filters: $filters, take: $take){id createdAt metadata} id} }"}', :headers => {'Content-Type' => 'application/json'} ).body
    all_transactions = JSON.parse(transactions)

    if all_transactions['data']['generativeToken'].present?
      all_transactions = all_transactions['data']['generativeToken']['actions']

      if all_transactions.count > 0 
        avg = all_transactions.sum {|h| h['metadata']['price'].to_i }.to_f / all_transactions.count

        token.sec_avg_recent = avg      
        token.save
      end
    end
  end
end
