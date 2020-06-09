class CreateModification < ActiveRecord::Migration
  def change
    create_table :modifications do |t|
      t.string :object_type
      t.integer :object_id
      t.integer :user_id, limit: 8
      t.timestamps null: false
    end
  end
end
