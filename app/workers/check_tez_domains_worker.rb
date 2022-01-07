class CheckTezDomainsWorker
  include Sidekiq::Worker

  def perform(wallet_address)
    return unless wallet_address.present?
    
    wallet = Wallet.find_or_create_by(address: wallet_address)

    domain_check = HTTParty.post("https://api.tezos.domains/graphql", :body => '{"operationName":null,"variables":{},"query":"{reverseRecords(where: {address: {in: [\"'+ wallet_address +'\"]}}) {items {address domain {name}}}}"}', :headers => {'Content-Type' => 'application/json'} ).body
    domain_check_data = JSON.parse(domain_check)

    if domain_check_data['data']['reverseRecords']['items'].present?
      if domain_check_data['data']['reverseRecords']['items'].first['domain'].present?
        address = domain_check_data['data']['reverseRecords']['items'].first['domain']['name']

        wallet.update(domain: address)
      end
    end
  end
end
