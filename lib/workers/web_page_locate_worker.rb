#
# My Internet Color
# a piece by @gleuch <http://gleu.ch>
# (c)2014, all rights reserved
#
# -----------------------------------------------------------------------------
#
# Web Page Locate Worker, for Sidekiq
# - domain name ip address lookup, get geo info for ip address
#
#


class WebPageLocateWorker

  include Sidekiq::Worker


  def perform(uuid)
    # Retry again in 1 hour if connection worker detects no connection or manually paused.
    WebPageLocateWorker.perform_in(1.hour, uuid) and return if File.exists?(File.join(APP_ROOT, 'tmp', 'connection.txt')) || File.exists?(File.join(APP_ROOT, 'tmp', 'paused.txt'))

    locate(uuid)
  end

  def locate(uuid)
    # Find web page
    page = WebPage.find(uuid) rescue nil
    return if page.blank?

    # Get hostname ip address
    ip_address = TCPSocket.open(page.uri.host, page.uri.port || (page.uri.scheme == 'https' ? 443 : 80)) {|s| s.peeraddr(:hostname)[3]}

    # Find or create a new web page location by ip address by cached ip/geo lookup. (Otherwise would be billions of facebook.com lookups :P)
    page_location = WebPageLocation.where(ip_address: ip_address).first_or_create rescue nil

    # Update web page with location if location was resolved
    page.update(located: true, ip_address: ip_address, web_page_location_id: page_location.id) unless page_location.blank? || page_location.new_record?
  end

end