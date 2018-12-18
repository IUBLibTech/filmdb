class CorrectBadTitleDateParses < ActiveRecord::Migration
  def up
    TitleDate.where("created_at != updated_at").each do |td|
      td.reparse_date
      td.save
    end
  end

  def down
    # no reversing
  end
end
