module ApplicationHelper
  def number_to_tez(number)
    number.to_f / 1000000
  end

  def display_tez(number)
    "#{number_with_delimiter(number_to_tez(number).round(2).to_s.sub(/\.?0+$/, ''))} tez"
  end

  def ipfs_image(url)
    if url.include?('ipfs:')
      token = url.gsub('ipfs://','')
      "https://cloudflare-ipfs.com/ipfs/#{token}/"
    else
      url
    end
  end
end
