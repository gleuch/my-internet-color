class WebPage < ActiveRecord::Base

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

  belongs_to :web_page_location, counter_cache: true


  # Validations & Callbacks ---------------------------------------------------

  validates :url, presence: true, format: {with: /\Ahttp(s)?:\/\//i}

  before_create :generate_host
  after_commit :queue_processing, on: :create


  # Scopes --------------------------------------------------------------------

  scope :located, -> { where(located: true) }
  scope :colored, -> { where(colored: true) }
  default_scope -> { where("#{self.table_name}.status > ?", 0) }


  # Class Methods -------------------------------------------------------------

  # Returns the average color for a given column
  def self.color_avg(v); where("#{self.table_name}.#{v} IS NOT NULL").average(v).to_f; end

  # Returns the RGB color average
  def self.avg_rgb_color; [color_avg(:rgb_color_red), color_avg(:rgb_color_green), color_avg(:rgb_color_blue)]; end

  # Returns the hex code for the RGB average color
  def self.avg_hex_color; ("%02x%02x%02x" % avg_rgb_color).upcase; end


  # Methods -------------------------------------------------------------------

  # Parse URL
  def uri; @@uri ||= Addressable::URI.parse(self.url); end

  # RGB array
  def rgb_color; [self.rgb_color_red, self.rgb_color_green, self.rgb_color_blue]; end


private

  # Store site url and domain tld info
  def generate_host
    uri = Addressable::URI.parse(self.url)
    self.site = uri.site
    self.domain_tld = [uri.domain,uri.tld].join('.')
  end

  # Queue up jobs for getting location, color, etc.
  def queue_processing
    WebPageLocateWorker.perform_async(self.uuid)
    WebPageColorWorker.perform_async(self.uuid)
  end

end