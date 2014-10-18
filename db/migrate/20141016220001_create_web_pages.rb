class CreateWebPages < ActiveRecord::Migration

  def change
    create_table :web_pages do |t|
      t.string      :uuid

      # Site/domain info
      t.text        :url
      t.string      :site
      t.string      :domain_tld
      t.string      :ip_address

      # Color info
      t.string      :hex_color
      t.decimal     :rgb_color_red
      t.decimal     :rgb_color_green
      t.decimal     :rgb_color_blue

      # Location info
      t.integer     :web_page_location_id

      # Statuses
      t.integer     :browse_histories_count,    default: 0
      t.boolean     :located,                   default: false
      t.boolean     :colored,                   default: false
      t.integer     :status,                    default: 1
      t.timestamps
    end

    add_index :web_pages, [:uuid], unique: true
    add_index :web_pages, [:domain_tld]
  end

end