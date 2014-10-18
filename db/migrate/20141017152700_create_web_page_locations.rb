class CreateWebPageLocations < ActiveRecord::Migration

  def change
    create_table :web_page_locations do |t|
      t.string      :uuid

      # Site/domain info
      t.string      :ip_address

      # Location
      t.float       :lat
      t.float       :lng
      t.string      :country
      t.string      :country_code
      t.string      :region
      t.string      :region_code
      t.string      :city
      t.string      :postal_code
      t.integer     :metro_code
      t.integer     :area_code

      # Statuses
      t.integer     :web_pages_count,           default: 0
      t.integer     :status,                    default: 0
      t.timestamps
    end

    add_index :web_page_locations, [:uuid], unique: true
    add_index :web_page_locations, [:ip_address], unique: true
  end

end