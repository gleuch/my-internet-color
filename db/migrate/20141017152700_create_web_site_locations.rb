class CreateWebSiteLocations < ActiveRecord::Migration

  def change
    create_table :web_site_locations do |t|
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
      t.integer     :web_sites_count,           default: 0
      t.integer     :status,                    default: 0
      t.timestamps
    end

    add_index :web_site_locations, [:uuid], unique: true
    add_index :web_site_locations, [:ip_address], unique: true
  end

end