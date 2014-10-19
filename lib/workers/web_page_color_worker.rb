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


class WebPageColorWorker

  include Sidekiq::Worker


  def perform(uuid)
    color(uuid)
  end

  def color(uuid)
    # Find web page
    web_page = WebPage.find(uuid) rescue nil
    return if web_page.blank?

    # Get tmp filename
    fname = File.join(APP_ROOT, 'tmp', [web_page.uuid, :png].join('.'))

    begin
      # Capture
      s = shot.capture(web_page.url, fname, width: 1, height: 1, quality: 100)

      # Process for color
      img = MiniMagick::Image.open(fname)
      hex = img.pixel_at(0,0).upcase.gsub(/^\#/,'')
      rgb = Color::RGB.from_html(hex)

      # Update web web_page
      web_page.update(colored: true, hex_color: hex, rgb_color_red: rgb.red, rgb_color_green: rgb.green, rgb_color_blue: rgb.blue)

    rescue => err

      # Decide whether to raise error (allow sidekiq retry again later)
      case err.to_s
        when /time(ed\s)?out|phantomjs\sclient\sdied/i
          raise "WorkerTimeoutError"
        when NoMethodError
          raise "WorkerError"
      end

    # Make sure tmp file is removed
    ensure
      Capybara.reset_sessions!
      FileUtils.rm(fname, force: true)
    end
  end


private

  def shot
    unless defined?(@@shot)
      # Puffing-billy proxy
      Billy.register_drivers
      Billy.configure do |c|
        c.cache = true
        c.cache_request_headers = false
        c.path_blacklist = []
        c.persist_cache = true
        c.ignore_cache_port = true # defaults to true
        c.non_successful_cache_disabled = false
        c.non_successful_error_level = :warn
        c.non_whitelisted_requests_disabled = false
        c.cache_path = 'tmp/requests/'

        # Suppress logging
        c.logger = Logger.new('/dev/null')

        # If there are URL paths to block, add them here (share buttons, ads, etc)
        c.ignore_params = [
          'http://www.google-analytics.com/__utm.gif',
          'https://r.twimg.com/jot',
          'http://p.twitter.com/t.gif',
          'http://p.twitter.com/f.gif',
          'http://www.facebook.com/plugins/like.php',
          'https://www.facebook.com/dialog/oauth',
          'http://cdn.api.twitter.com/1/urls/count.json',
          'https://analytics.twitter.com:443/i/adsct',
          'http://ping.chartbeat.net/ping',
          'https://p.brilig.com:443/contact/sync'
        ]
      end

      # Load webshot
      @@shot = Webshot::Screenshot.instance

      # Configure Capybara/Poltergeist/PhantomJS
      @@shot.page.driver.headers = {"User-Agent" => CRAWLER_USER_AGENT}

      # Set poltergeist_billy as capybara driver
      Capybara.current_driver = :poltergeist_billy
      Capybara.javascript_driver = :poltergeist_billy

    end

    @@shot
  end

end