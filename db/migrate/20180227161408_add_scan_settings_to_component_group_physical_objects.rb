class AddScanSettingsToComponentGroupPhysicalObjects < ActiveRecord::Migration
  def change
    # # move scan settings to the join table
    add_column :component_group_physical_objects, :scan_resolution, :string
    add_column :component_group_physical_objects, :clean, :string
    add_column :component_group_physical_objects, :hand_clean_only, :boolean
    add_column :component_group_physical_objects, :return_on_reel, :boolean
    add_column :component_group_physical_objects, :color_space, :string
    #
    # # add active_component_group_scan settings
    add_column :physical_objects, :active_scan_settings_id, :integer, limit: 8

    cgs = ComponentGroup.all
    cgs.each_with_index do |cg, index|
      cg.component_group_physical_objects.each do |cgpo|
        puts "Processing CG #{index+1} of #{cgs.size}"
        cgpo.update_attributes(scan_resolution: cg.scan_resolution, clean: cg.clean, hand_clean_only: cg.hand_clean_only, return_on_reel: cg.return_on_reel, color_space: cg.color_space)
      end
    end

    pos = PhysicalObject.where("component_group_id IS NOT null")
    pos.each_with_index do |p, index|
      puts "Processing Physical Object #{index+1} of #{pos.size}"
      cgpo = p.component_group_physical_objects.where(component_group_id: p.active_component_group.id).first
      p.update_attributes(active_scan_settings: cgpo)
    end
  end
end
