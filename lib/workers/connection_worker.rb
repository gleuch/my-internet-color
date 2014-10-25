#
# My Internet Color
# a piece by @gleuch <http://gleu.ch>
# (c)2014, all rights reserved
#
# -----------------------------------------------------------------------------
#
# Web Page Color Worker, for Sidekiq
# - takes screenshot of web page url, determined singular pixel color
#
#


class ConnectionWorker

  include Sidekiq::Worker
  sidekiq_options queue: :high


  def perform
    available?
    ConnectionWorker.perform_at(10.seconds)
  end

  # If connection not available, touch a file that other workers check to know if to continue or not
  def available?
    fname = File.join(APP_ROOT, 'tmp', 'connection.txt')

    Socket.getaddrinfo("google.com", "http")
    FileUtils.rm(fname, force: true) rescue true# if good
    true

  rescue => err
    File.open(fname, 'w') {|f| f << '1'}
    false
  end

end