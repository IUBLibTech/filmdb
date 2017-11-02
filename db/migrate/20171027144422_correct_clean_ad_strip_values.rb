class CorrectCleanAdStripValues < ActiveRecord::Migration
  def change
    ComponentGroup.where(clean: '1').each do |cg|
	    cg.update_attributes(clean: 'Yes')
    end
	  bad_vals = {'0' => '0.0', '1' => '1.0', '2' => '2.0', '3' => '3.0 (place for freezer)'}
	  bad_vals.keys.each do |k|
		  PhysicalObject.where(ad_strip: k).each do |p|
			  p.update_attributes(ad_strip: bad_vals[k])
		  end
	  end
  end
end
