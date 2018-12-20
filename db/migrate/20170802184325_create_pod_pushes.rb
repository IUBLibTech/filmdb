class CreatePodPushes < ActiveRecord::Migration
  def change
    create_table :pod_pushes do |t|
      t.text :response
      t.integer :cage_id, limit: 8
      t.timestamps
    end
  end
end
