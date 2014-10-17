class WebSiteLocateWorker

  include Sidekiq::Worker


  def perform(uuid)
    locate(uuid)
  end

  def locate(uuid)
    # Find web site
    site = WebSite.find(uuid) rescue nil
    return if site.blank?

    # Get hostname ip address
    ip_address = TCPSocket.open(site.uri.host, site.uri.port || (site.uri.scheme == 'https' ? 443 : 80)) {|s| s.peeraddr(:hostname)[3]}

    # Find or create a new web site location by ip address by cached ip/geo lookup. (Otherwise would be billions of facebook.com lookups :P)
    site_location = WebSiteLocation.where(ip_address: ip_address).first_or_create rescue nil

    # Update web site with location if location was resolved
    site.update(located: true, ip_address: ip_address, web_site_location_id: site_location.id) unless site_location.blank? || site_location.new_record?
  end

end