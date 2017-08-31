class ConvertTitleDatesToYears < ActiveRecord::Migration
  def change
    TitleDate.reset_column_information
    TitleDate.transaction do
		  TitleDate.all.each do |td|
			  if (!/\A[+]?\d+\z/.match(td.date).nil? && td.date.length == 4)
				  td.update_attributes!(year: td.date.to_i, date: nil, date_type: 'Publication Date')
			  end
		  end
	  end
  end
end
