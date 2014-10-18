class WebPageLocation < ActiveRecord::Base

  # Variables & Includes ------------------------------------------------------

  include Uuidable

  extend FriendlyId
  friendly_id :ip_address, use: [:finders]

  # Status of geo lookup
  enum status: {not_located: 0, located: 1}


  # Associations --------------------------------------------------------------

  has_many :web_pages


  # Validations & Callbacks ---------------------------------------------------

  before_create :get_location


  # Scopes --------------------------------------------------------------------


  # Class Methods -------------------------------------------------------------


  # Methods -------------------------------------------------------------------

  # Quick method to output address info
  def location_address
    [self.city, self.region, self.postal_code, self.country].reject(&:blank?).compact.join(', ')
  end

  # Get the location via ip lookup via geocoder
  def get_location
    geo = Geocoder.search(self.ip_address).first rescue nil

    if geo.present? && geo.data.present?
      addy = %w(city region_name country_name).map{|n| geo.data[n]}.reject(&:blank?).compact

      unless addy.include?('Reserved')
        self.assign_attributes(lat: geo.data['latitude'], lng: geo.data['longitude'], country: geo.data['country_name'], country_code: geo.data['country_code'],region: geo.data['region_name'], region_code: geo.data['region_code'], city: geo.data['city'], postal_code: geo.data['zipcode'], metro_code: geo.data['metro_code'], area_code: geo.data['area_code'])
      else
        self.assign_attributes(country: 'Reserved', country_code: 'RD', lat: 0.0, lng: 0.0)
      end

      self.assign_attributes(status: :located)
    end
  end

private


end