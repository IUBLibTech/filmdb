class CorrectBestCopyScanResolution < ActiveRecord::Migration
  def change
    ComponentGroup.where("group_type = 'Best Copy (MDPI)' AND scan_resolution is not null").each do |cg|
      cg.update(scan_resolution: nil)
    end
  end
end
