class CreateWebSites < ActiveRecord::Migration

  def change
    create_table :web_sites do |t|
      t.string      :uuid
      t.text        :url
      t.string      :site
      t.string      :domain_tld
      t.string      :hex_color
      t.integer     :browse_histories_count,   default: 0
      t.integer     :status,                    default: 1
      t.timestamps
    end

    add_index :web_sites, [:uuid], unique: true
    add_index :web_sites, [:domain_tld]
  end

end