APP_ROOT = File.expand_path('..', File.dirname(__FILE__))
DEBUG = false
TIME_START = Time.now

require File.join(APP_ROOT, 'config.rb')


require 'socket'
require 'json'

server = TCPServer.open(2000)
puts "Listening on port 2000"

loop do
  Thread.start(server.accept) do |client|
    puts "-"*80

    ln = client.gets.chomp
    if ln.match(/^[A-Z]+\s\/(http.*)\sHTTP\/1\.1$/)
      url = ln.gsub(/^[A-Z]+\s\/(http.*)\sHTTP\/1\.1$/, '\1')
      # BrowseHistory.add(url)
      resp = {success: true, url: url}.to_json
    else
      resp = {success: false}.to_json
    end

    client.puts ["HTTP/1.1 200 OK","Date: #{Time.now.strftime('%a, %d %b %Y %H:%M:%S %Z')}","Server: MyInternetColor/1.0","Content-Type: text/html; charset=utf-8","Content-Length: #{resp.length}\r\n\r\n"].join("\r\n")
    client.puts resp
    client.close
  end
end