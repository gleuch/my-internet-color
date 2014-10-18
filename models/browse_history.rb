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

  default_scope -> { where('status > ?', 0) }


  # Class Methods -------------------------------------------------------------

  def self.add(url, ip=nil)
    return false if url.blank?

    page = WebPage.where('LOWER(url) = ?', url.downcase).first_or_create{|ws| ws.url = url}# rescue nil
    return false if page.new_record?

    BrowseHistory.create(web_page_id: page.id, ip_address: ip)
  end


  # Methods -------------------------------------------------------------------



private


end