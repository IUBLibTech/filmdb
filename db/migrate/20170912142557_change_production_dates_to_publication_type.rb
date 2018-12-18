class ChangeProductionDatesToPublicationType < ActiveRecord::Migration
  def change
    TitleDate.all.each do |td|
      td.update_attributes(date_type: 'Publication Date')
    end
  end
end
