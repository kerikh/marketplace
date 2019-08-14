class AddIidToProjectItem < ActiveRecord::Migration[5.2]
  def up
    add_column :project_items, :iid, :integer, index: true
  end

  def down
    remove_column :project_items, :iid
  end
end
