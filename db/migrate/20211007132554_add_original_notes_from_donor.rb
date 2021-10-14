class AddOriginalNotesFromDonor < ActiveRecord::Migration
  def change
    add_column :equipment_technologies, :original_notes_from_donor, :text
  end
end
