class CreateTablePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :name
    end
    add_column :archives, :package_id, :integer
  end
end
