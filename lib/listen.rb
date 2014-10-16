APP_ROOT = File.expand_path('..', File.dirname(__FILE__))
DEBUG = false
TIME_START = Time.now

require File.join(APP_ROOT, 'config.rb')


require 'socket'
require 'json'

# Open server, wait for requests
server = TCPServer.open(2000)
loop do
  if client = server.accept #Thread.start(server.accept) do |client|

    # Get request header
    req = client.gets.chomp

    resp = begin
      rgx = /^[A-Z]+\s\/\?(.*)\sHTTP\/1\.1$/

      # Determine if request is for a URL (http or https)
      raise 'InvalidUri' unless req.match(rgx)

      # Parse URL, add to browse history
      params = Addressable::URI.parse(req.gsub(rgx, 'http://localhost/?\1')).query_values rescue nil
      raise 'InvalidParams' unless params.present?
      
      hist = BrowseHistory.add(params['url'], params['ip'])
      raise 'NotSaved' unless hist.present?

      {success: true, url: params['url']}

    rescue => err
      {success: false, message: err.to_s}
    end

    resp = resp.to_json

    # Return request status
    client.puts ["HTTP/1.1 200 OK","Date: #{Time.now.strftime('%a, %d %b %Y %H:%M:%S %Z')}","Server: MyInternetColor/1.0","Content-Type: text/html; charset=utf-8","Content-Length: #{resp.length}\r\n\r\n"].join("\r\n")
    client.puts resp
    client.close
  end
end