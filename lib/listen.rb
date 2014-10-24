#
# My Internet Color
# a piece by @gleuch <http://gleu.ch>
# (c)2014, all rights reserved
#
# -----------------------------------------------------------------------------
#
# Listener App
# - opens port, listens to url requests from browser extension
#
#


# DEFAULT OPTIONS
APP_ROOT = File.expand_path('..', File.dirname(__FILE__))
DEBUG = false
TIME_START = Time.now

# LOAD CONFIG
%w{socket}.each{|r| require r}
require File.join(APP_ROOT, 'config.rb')


# Open server, wait for requests
server = TCPServer.open(2000)
loop do
  if client = server.accept #Thread.start(server.accept) do |client|

    # Get request header
    req = client.gets.chomp

    # Create response based on status of browse history save
    resp = begin
      rgx = /^[A-Z]+\s\/\?(.*)\sHTTP\/1\.1$/

      # Determine if request is for a URL (http or https)
      raise 'InvalidUri' unless req.match(rgx)

      # Parse URL, add to browse history
      params = Addressable::URI.parse(req.gsub(rgx, 'http://localhost/?\1')).query_values rescue nil
      raise 'InvalidParams' unless params.present?

      if params['color'].present?
        ctype = 'text/plain'
        {
          hex_color: BrowseHistory.today.avg_hex_color,
          pages_count: BrowseHistory.today.count,
          pages_with_color_count: BrowseHistory.today.with_color.count
        }
        
      else
        # Base64 unencoded unescaped url string
        decodedUrl = Addressable::URI::unescape(Addressable::URI.unencode(Base64.decode64(params['url']))) rescue nil
        raise 'InvalidUrl' if decodedUrl.blank?

        # Attempt to add to browse history
        hist = BrowseHistory.add(decodedUrl, params['ip'])
        raise 'NotSaved' unless hist.present?

        puts "Added: #{hist.web_page.url}"

        {success: true, url: params['url']}
      end

    rescue => err
      {success: false, message: err.to_s}
    end

    resp = resp.to_json

    # Return request status
    client.puts ["HTTP/1.1 200 OK","Date: #{Time.now.strftime('%a, %d %b %Y %H:%M:%S %Z')}","Server: MyInternetColor/1.0","Content-Type: #{ctype || 'image/png'}; charset=utf-8","Content-Length: #{resp.length}\r\n\r\n"].join("\r\n")
    client.puts resp
    client.close
  end
end
