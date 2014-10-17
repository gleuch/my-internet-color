class WebSite < ActiveRecord::Base

  # Variables & Includes ------------------------------------------------------

  include Uuidable

  extend FriendlyId
  friendly_id :uuid, use: [:finders]

  #
  enum status: {
    deleted:      0,
    active:       1,
    hidden:       2
  }


  # Associations --------------------------------------------------------------

  has_many :browse_histories

  belongs_to :web_site_location, counter_cache: true


  # Validations & Callbacks ---------------------------------------------------

  validates :url, presence: true, format: {with: /\Ahttp(s)?:\/\//i}

  before_create :generate_host
  after_create :queue_processing


  # Scopes --------------------------------------------------------------------

  scope :located, -> { where(located: true) }
  scope :colored, -> { where(colored: true) }
  default_scope -> { where('status > ?', 0) }


  # Class Methods -------------------------------------------------------------

  def self.color_avg(v); where("#{v} IS NOT NULL").average(v).to_f; end
  def self.avg_hex_color; ("%02x%02x%02x" % avg_rgb_color).upcase; end
  def self.avg_rgb_color; [color_avg(:rgb_color_red), color_avg(:rgb_color_green), color_avg(:rgb_color_blue)]; end


  # Methods -------------------------------------------------------------------

  def uri; @@uri ||= Addressable::URI.parse(self.url); end

  def rgb_color; [self.rgb_color_red, self.rgb_color_green, self.rgb_color_blue]; end

  def tmp_filename(ext=:png); [self.uuid, ext].join('.'); end


private

  def generate_host
    uri = Addressable::URI.parse(self.url)
    self.site = uri.site
    self.domain_tld = [uri.domain,uri.tld].join('.')
  end

  def queue_processing
    
  end

end