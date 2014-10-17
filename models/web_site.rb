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


  # Methods -------------------------------------------------------------------

  def uri; @@uri ||= Addressable::URI.parse(self.url); end


private

  def generate_host
    uri = Addressable::URI.parse(self.url)
    self.site = uri.site
    self.domain_tld = [uri.domain,uri.tld].join('.')
  end

  def queue_processing
    
  end

end