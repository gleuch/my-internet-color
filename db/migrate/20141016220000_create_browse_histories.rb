class CreateBrowseHistories < ActiveRecord::Migration

  def change
    create_table :browse_histories do |t|
      t.integer     :web_page_id
      t.string      :ip_address
      t.integer     :status,          default: 1
      t.datetime    :created_at
    end

    add_index :browse_histories, [:web_page_id]
  end

end