class WebSite < ActiveRecord::Base

  # Variables & Includes ------------------------------------------------------

  include Uuidable

  extend FriendlyId
  friendly_id :uuid, use: [:finders]

  #
  enum status: {
    deleted:      0,
    pending:      1,
    located:      2,
    colored:      3,
    not_found:    11,
    not_located:  12,
    not_colored:  13,
  }


  # Associations --------------------------------------------------------------

  has_many :browse_histories


  # Validations & Callbacks ---------------------------------------------------

  validates :url, presence: true, format: {with: /\Ahttp(s)?:\/\//i}

  before_create :generate_host
  after_create :queue_processing


  # Scopes --------------------------------------------------------------------

  default_scope -> { where('status > ?', 0) }


  # Class Methods -------------------------------------------------------------


  # Methods -------------------------------------------------------------------



private

  def generate_host
    uri = Addressable::URI.parse(self.url)
    self.site = uri.site
    self.domain_tld = [uri.domain,uri.tld].join('.')
  end

  def queue_processing
    #
  end

end