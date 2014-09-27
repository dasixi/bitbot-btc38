require 'bitbot'
require 'json'
require 'net/http'

module BitBot
  module Btc38

    def ticker
      resp = get('http://api.btc38.com/v1/ticker.php?c=btsx&mk_type=cny')

      check_response(resp)

      original = resp['ticker']
      map  = {sell: :ask, buy: :bid}

      Ticker.new rekey(original, map).merge(original: original, agent: self)
    end

    def offers
      #uri = URI('http://api.btc38.com/v1/depth.php?c=btsx&mk_type=cny')
      #body = Net::HTTP.get_response(uri).body
      #resp = JSON.parse body

      resp = get('http://api.btc38.com/v1/depth.php?c=btsx&mk_type=cny')
      check_response(resp)

      asks = resp['asks'].collect do |arr|
        Offer.new price: arr[0], amount: arr[1], original: arr, agent: self
      end

      bids = resp['bids'].collect do |arr|
        Offer.new price: arr[0], amount: arr[1], original: arr, agent: self
      end

      {asks: asks, bids: bids}
    end

    private

    def get(url)
      uri = URI(url)

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      request.initialize_http_header({"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.124 Safari/537.36"})

      resp = http.request(request)
      JSON.parse resp.body
    end

    def check_response(response)
    end

  end
end

BitBot.define :btc38, BitBot::Btc38
