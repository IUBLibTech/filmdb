class ChangeMauerSoundFieldToFormatType < ActiveRecord::Migration[5.0]
  def change
    rename_column :films, :sound_configuration_multi_track,:sound_format_optical_variable_area_maurer
  end
end
