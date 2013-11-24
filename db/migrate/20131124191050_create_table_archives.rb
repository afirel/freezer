class CreateTableArchives < ActiveRecord::Migration
  def change
    create_table :archives do |t|
      t.text    :archive_id
      t.integer :size
      t.string  :vault
      t.string  :treehash
      t.integer :treehash_chunk_size
      t.string  :sha256
      t.text    :description
      t.string  :original_path
      t.timestamps
    end
  end
end
