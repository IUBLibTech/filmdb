class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.string :title, required: true
      t.string :description
      t.timestamps
    end
  end
end
