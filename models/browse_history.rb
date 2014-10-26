class BrowseHistory < ActiveRecord::Base

  # Variables & Includes ------------------------------------------------------

  #
  enum status: {
    deleted:    0,
    active:     1,
    incognito:  2,
  }


  # Associations --------------------------------------------------------------

  belongs_to :web_page, counter_cache: true


  # Validations & Callbacks ---------------------------------------------------


  # Scopes --------------------------------------------------------------------

  scope :yesterday, -> { on_date(Date.today-1.day)}
  scope :today, -> { on_date(Date.today) }
  scope :on_date, ->(d) { where("date(#{self.table_name}.created_at) = ?", d) }
  scope :between_dates, ->(s,e) { where("date(#{self.table_name}.created_at) >= ? and date(#{self.table_name}.created_at) <= ?", s,e) }
  scope :days, ->(n) { where("#{self.table_name}.created_at >= ?", Date.today - (n-1).days)}
  scope :with_color, -> { joins(:web_page).where("#{WebPage.table_name}.colored = ?",true) }
  default_scope -> { where("#{self.table_name}.status > ?", 0) }


  # Class Methods -------------------------------------------------------------

  def self.add(url, ip=nil)
    return false if url.blank?

    page = WebPage.where('LOWER(url) = ?', url.downcase).first_or_create{|ws| ws.url = url}# rescue nil
    return false if page.new_record?

    BrowseHistory.create(web_page_id: page.id, ip_address: ip)
  end


  def self.color_avg(v); where("#{WebPage.table_name}.#{v} IS NOT NULL").average(v).to_f; end

  def self.avg_rgb_color
    obj = joins(:web_page).where("#{WebPage.table_name}.colored = ?",true)
    [obj.color_avg(:rgb_color_red), obj.color_avg(:rgb_color_green), obj.color_avg(:rgb_color_blue)]
  end

  def self.avg_hex_color
    ("%02x%02x%02x" % avg_rgb_color).upcase
  end




  # Methods -------------------------------------------------------------------



private


end