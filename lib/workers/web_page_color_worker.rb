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
    page = WebPage.find(uuid) rescue nil
    return if page.blank?

    # Get tmp filename
    fname = File.join(APP_ROOT, 'tmp', [page.uuid, :png].join('.'))

    begin
      # Start webshot
      shot = Webshot::Screenshot.instance#(user_agent: CRAWLER_USER_AGENT)

      # Capture
      shot.capture(page.url, fname, width: 1, height: 1, quality: 100)

      # Process for color
      img = MiniMagick::Image.open(fname)
      hex = img.pixel_at(0,0).upcase.gsub(/^\#/,'')
      rgb = Color::RGB.from_html(hex)

      # Update web page
      page.update(colored: true, hex_color: hex, rgb_color_red: rgb.red, rgb_color_green: rgb.green, rgb_color_blue: rgb.blue)

    rescue => err
      puts "Error: #{err.inspect}"

    # Make sure tmp file is removed
    ensure
      FileUtils.rm(fname, force: true)
    end
  end

end