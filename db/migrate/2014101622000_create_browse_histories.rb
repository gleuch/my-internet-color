class CreateBrowseHistories < ActiveRecord::Migration

  def change
    create_table :browse_history do |t|
      t.string      :ip_address
      t.string      :web_site_id
      t.datetime    :created_at
    end
  end

end