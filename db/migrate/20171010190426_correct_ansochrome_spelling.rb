class CorrectAnsochromeSpelling < ActiveRecord::Migration
  def change
    rename_column :physical_objects, :color_bw_color_ansochrome, :color_bw_color_anscochrome
  end
end
