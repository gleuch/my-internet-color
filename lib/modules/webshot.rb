# modified from https://github.com/vitalie/webshot to fix errors and use billy_poltergeist

module Webshot

  ## Browser settings
  # Width
  mattr_accessor :width
  @@width = 1024

  # Height
  mattr_accessor :height
  @@height = 768

  # User agent
  mattr_accessor :user_agent
  @@user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.43 Safari/537.31"

  # Customize settings
  def self.setup
    yield self
  end

  # Capibara setup
  def self.capybara_setup!
    Billy.configure do |c|
      c.cache = true
      c.cache_request_headers = false
      c.path_blacklist = []
      c.persist_cache = true
      c.ignore_cache_port = true # defaults to true
      c.non_successful_cache_disabled = false
      c.non_successful_error_level = :warn
      c.non_whitelisted_requests_disabled = false
      # c.cache_path = 'tmp/requests/'

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

    # re-define poltergeist_billy to also ignore js errors
    Capybara.register_driver :poltergeist_billy do |app|
      Capybara::Poltergeist::Driver.new(app, {
        # Raise JavaScript errors to Ruby
        js_errors: false,
        # Additional command line options for PhantomJS
        phantomjs_options: [
          '--ignore-ssl-errors=yes',
          "--proxy=#{Billy.proxy.host}:#{Billy.proxy.port}"
        ],
      })
    end

    # By default Capybara will try to boot a rack application
    # automatically. You might want to switch off Capybara's
    # rack server if you are running against a remote application
    Capybara.run_server = false

    # Set poltergeist_billy as capybara driver
    Capybara.current_driver = :poltergeist_billy
    Capybara.javascript_driver = :poltergeist_billy
  end

  class Screenshot
    include Capybara::DSL
    include Singleton

    def initialize(opts = {})
      Webshot.capybara_setup!
      width  = opts.fetch(:width, Webshot.width)
      height = opts.fetch(:height, Webshot.height)
      user_agent = opts.fetch(:user_agent, Webshot.user_agent)

      # Browser settings
      page.driver.resize(1024, 1024)
      page.driver.headers = {"User-Agent" => CRAWLER_USER_AGENT}
      # page.driver.resize(width, height)
      # page.driver.headers = {
      #   "User-Agent" => user_agent,
      # }
    end

    # Captures a screenshot of +url+ saving it to +path+.
    def capture(url, path, opts = {})
      # Default settings
      width   = opts.fetch(:width, 120)
      height  = opts.fetch(:height, 90)
      gravity = opts.fetch(:gravity, "north")
      quality = opts.fetch(:quality, 85)

      # Reset session before visiting url
      Capybara.reset_sessions! rescue nil

      # Open page
      visit url

      # Timeout
      sleep opts[:timeout] || 1

      # Check status code
      status_code = page.driver.status_code.to_s.chomp
      err_code = nil
      err_code = true if status_code.blank? || status_code == 'false' || status_code != '200'
      err_code = false if status_code.match(/success|true/i)

      raise "InvalidResponseCode #{status_code}" if err_code

      tmp = Tempfile.new(["webshot-#{SecureRandom.hex(12)}", ".png"])
      tmp.close
      begin
        # Save screenshot to file
        page.driver.save_screenshot(tmp.path, full: true)

        # Resize screenshot
        thumb = MiniMagick::Image.open(tmp.path)
        if block_given?
          # Customize MiniMagick options
          yield thumb
        else
          thumb.combine_options do |c|
            c.thumbnail "#{width}x"
            c.background "white"
            c.extent "#{width}x#{height}"
            c.gravity gravity
            c.quality quality
          end
        end
    
        # Save thumbnail
        thumb.write path
        thumb
      ensure
        tmp.unlink
      end
    end
  end
end