class CreateBrowseHistories < ActiveRecord::Migration

  def change
    create_table :browse_histories do |t|
      t.string      :web_site_id
      t.string      :ip_address
      t.integer     :status,          default: 1
      t.datetime    :created_at
    end

    add_index :browse_histories, [:web_site_id]
  end

end