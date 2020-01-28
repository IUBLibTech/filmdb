class CorrectLostShrinkageValues < ActiveRecord::Migration[5.0]
  def up
    change_column :videos, :shrinkage, :float

    path = "#{Rails.root}/tmp/shrinkage_update.csv"
    begin
      @csv = CSV.read(path, headers: false)
    rescue
      @opened_file = File.open(path, "r:ISO-8859-1:UTF-8")
      @csv = CSV.parse(@opened_file, headers: false)
    end
    Film.transaction do
      change_column :films, :shrinkage, :float
      @csv.each_with_index do |row, i|
        next if i == 0
        puts "Row: #{i} of #{@csv.size}"
        film = PhysicalObject.find(row[0].to_i).specific
        raise "Couldn't find a Film with PO id: #{row[0]}" if film.nil?
        film.update(shrinkage: row[1].to_f)
      end
    end
  end

  def down
    change_column :films, :shrinkage, :integer
    change_column :videos, :shrinkage, :integer
  end
end
