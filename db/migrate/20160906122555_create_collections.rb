class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :name, unique: true
      t.timestamps
    end
  end
end
