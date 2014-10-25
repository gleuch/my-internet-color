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
    # Retry again in 1 hour if connection worker detects no connection or manually paused.
    WebPageColorWorker.perform_in(1.hour, uuid) and return if File.exists?(File.join(APP_ROOT, 'tmp', 'connection.txt')) || File.exists?(File.join(APP_ROOT, 'tmp', 'paused.txt'))

    color(uuid)
  end

  def color(uuid)
    # Find web page
    web_page = WebPage.find(uuid) rescue nil
    return if web_page.blank?

    # Get tmp filename
    fname = File.join(APP_ROOT, 'tmp/screenshots', "#{web_page.domain_tld}-#{web_page.uuid}.png")

    begin
      puts "[START] #{web_page.uuid} (#{web_page.url})"

      # Capture
      shot.capture(web_page.url, fname, width: 1, height: 1, quality: 100, browser_width: 1024, browser_height: 1024)

      # Process for color, hex & rgb
      img = MiniMagick::Image.open(fname)
      hex = img.pixel_at(0,0).upcase.gsub(/^\#/,'')
      rgb = Color::RGB.from_html(hex)

      # Update web web_page
      web_page.update(colored: true, hex_color: hex, rgb_color_red: rgb.red, rgb_color_green: rgb.green, rgb_color_blue: rgb.blue)

      puts "[DONE] #{web_page.uuid} (#{web_page.url}): ##{hex}"

    rescue => err
      puts "[ERROR] #{web_page.uuid} (#{web_page.url}): #{err.to_s}"
      raise err

    # Make sure tmp file is removed
    ensure
      FileUtils.rm(fname, force: true)
    end
  end


private

  def shot
    @@shot ||= Webshot::Screenshot.instance
  end

end