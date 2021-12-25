class SyncTokenWorker
  include Sidekiq::Worker

  def perform(token_id)
    require 'open-uri'

    token = Token.find_or_create_by(fxid: token_id)

    unless token.delisted == true
      begin
        doc = Nokogiri::HTML(URI.open("https://www.fxhash.xyz/marketplace/generative/#{token_id}"))
          
        token.name = doc.at('h3').text
        token.floor = doc.at('span:contains("Floor")').next_sibling.text == '/' ? nil : doc.at('span:contains("Floor")').next_sibling.text.gsub(' tez','').to_f
        token.median = doc.at('span:contains("Median")').next_sibling.text == '/' ? nil : doc.at('span:contains("Median")').next_sibling.text.gsub(' tez','').to_f
        token.total_listing = doc.at('span:contains("Items for sale")').next_sibling.text == '/' ? nil : doc.at('span:contains("Items for sale")').next_sibling.text.to_i
        token.highest_sold = doc.at('span:contains("Highest 2nd sale")').next_sibling.text == '/' ? nil : doc.at('span:contains("Highest 2nd sale")').next_sibling.text.gsub(' tez','').to_f
        token.lowest_sold = doc.at('span:contains("Lowest 2nd sale")').next_sibling.text == '/' ? nil : doc.at('span:contains("Lowest 2nd sale")').next_sibling.text.gsub(' tez','').to_f
        token.prim_total = doc.at('span:contains("1st sales")').next_sibling.text == '/' ? nil : doc.at('span:contains("1st sales")').next_sibling.text.gsub(' tez','').to_f
        token.sec_volume_tz = doc.at('span:contains("2nd sales (tez)")').next_sibling.text == '/' ? nil : doc.at('span:contains("2nd sales (tez)")').next_sibling.text.gsub(' tez','').to_f
        token.sec_volume_nb = doc.at('span:contains("2nd sales (nb)")').next_sibling.text == '/' ? nil : doc.at('span:contains("2nd sales (nb)")').next_sibling.text.to_i
        token.sec_volume_tz_24 = doc.at('span:contains("2nd sales 24h (tez)")').next_sibling.text == '/' ? nil : doc.at('span:contains("2nd sales 24h (tez)")').next_sibling.text.gsub(' tez','').to_f
        token.sec_volume_nb_24 = doc.at('span:contains("2nd sales 24h (nb)")').next_sibling.text == '/' ? nil : doc.at('span:contains("2nd sales 24h (nb)")').next_sibling.text.to_i
      rescue OpenURI::HTTPError => error
        token.delisted = true
      ensure
        token.save
      end 
    end
  end
end
