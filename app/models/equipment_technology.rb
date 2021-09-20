class EquipmentTechnology < ActiveRecord::Base
  include ApplicationHelper
  acts_as :physical_object
  validates :iu_barcode, iu_barcode: true

  TYPE_FIELDS = [
    :type_camera, :type_camera_accessory, :type_editor, :type_flatbed, :type_lens, :type_light, :type_reader,
    :type_photo_equipment, :type_projection_screen, :type_projector, :type_rewind, :type_shrinkage_gauge,
    :type_squawk_box, :type_splicer, :type_supplies, :type_synchronizer, :type_viewer, :type_video_deck,
    :type_other
  ]
  TYPE_FIELDS_HUMANIZED = {
    type_camera: 'Camera', type_camera_accessory: "Camera Accessory", type_editor: "Editor", type_flatbed: "Faltbed",
    type_lens: "Lens", type_light: "Light", type_reader: "Reader", type_photo_equipment: "Photo Equipment",
    type_projection_screen: "Projection Screen", type_projector: "Projector", type_rewind: "Rewind", type_shrinkage_gauge: "Shrinkage Gauge",
    type_squawk_box: "Squawk Box", type_splicer: "Splicer", type_supplies: "Supplies", type_synchronizer: "Synchronizer",
    type_viewer: "Viewer", type_video_deck: "Video Deck", type_other: "Other"
  }
  HUMANIZED_SYMBOLS = TYPE_FIELDS_HUMANIZED

  def initialize(args = {})
    super
    if args.is_a? ActionController::Parameters
      args.keys.each do |a|
        self.send(a.dup << "=", args[a])
      end
    elsif args.is_a? Hash
      args.keys.each do |k|
        self.send((k.to_s << "=").to_sym, args[k])
      end
    else
      raise "What is args?!?!?"
    end
  end

  # overridden to provide for more human readable attribute names for things like :sample_rate_32k
  def self.human_attribute_name(attribute, options = {})
    self.const_get(:HUMANIZED_SYMBOLS)[attribute.to_sym] || super
  end

  def humanize_boolean_fields(field_names)
    str = ""
    field_names.each do |f|
      str << (self.specific[f] ? (str.length > 0 ? ", " << self.class.human_attribute_name(f) : self.class.human_attribute_name(f)) : "")
    end
    str
  end

  def gauge
    humanize_boolean_fields EquipmentTechnology::TYPE_FIELDS
  end

  def medium_name
    "#{medium} [#{humanize_boolean_fields EquipmentTechnology::TYPE_FIELDS}]"
  end

  def self.write_xlsx_header_row(worksheet)
    raise "No Spreadsheet header specification for EquipmentTechnology Physical Objects"
  end
  def write_xlsx_row(t, worksheet)
    raise "No Spreadsheet row specification for EquipmentTechnology Physical Objects"
  end
  def to_xml(options)
    raise "No specification for how to export EquipmentTechnology Physical Objects to XML"
  end


end
