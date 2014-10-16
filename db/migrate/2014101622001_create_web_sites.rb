class CreateWebSites < ActiveRecord::Migration

  def change
    create_table :web_site do |t|
      t.string      :uuid
      t.text        :url
      t.string      :web_site_id
      t.integer     :status,              default: 0
      t.string      :hex_color
      t.timestamps
    end
  end

end