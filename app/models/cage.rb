class Cage < ActiveRecord::Base
  belongs_to :top_shelf, foreign_key: "top_shelf_id", class_name: "CageShelf", dependent: :delete
  belongs_to :middle_shelf, foreign_key: "middle_shelf_id", class_name: "CageShelf", dependent: :delete
  belongs_to :bottom_shelf, foreign_key: "bottom_shelf_id", class_name: "CageShelf", dependent: :delete

  accepts_nested_attributes_for :top_shelf
  accepts_nested_attributes_for :middle_shelf
  accepts_nested_attributes_for :bottom_shelf

  # place holders for the form submission of adding a physical object to a cage shelf: see cages_controller#add_physical_object_to_shelf
  attr_accessor :cage_shelf_id
  attr_accessor :physical_object_mdpi_barcode
  attr_accessor :physical_object_iu_barcode

  def initialize(*args)
    super
    self.top_shelf ||= CageShelf.new
    self.middle_shelf ||= CageShelf.new
    self.bottom_shelf ||= CageShelf.new
  end

  def top_shelf_identifier=(id)
    top_shelf ||= CageShelf.new
    top_shelf.identifier = id
  end
  def top_shelf_identifier
    top_shelf.identifier
  end
  def top_shelf_mdpi_barcode=(barcode)
    top_shelf ||= CageShelf.new
    top_shelf.mdpi_barcode = barcode
  end
  def top_shelf_mdpi_barcode
    top_shelf.mdpi_barcode
  end
  def top_shelf_notes=(notes)
    top_shelf ||= CageShelf.new
    top_shelf.notes = notes
  end
  def top_shelf_notes
    top_shelf.notes
  end

  def middle_shelf_identifier=(id)
    middle_shelf ||= CageShelf.new
    middle_shelf.identifier = id
  end
  def middle_shelf_identifier
    middle_shelf.identifier
  end
  def middle_shelf_mdpi_barcode=(barcode)
    middle_shelf ||= CageShelf.new
    middle_shelf.mdpi_barcode = barcode
  end
  def middle_shelf_mdpi_barcode
    middle_shelf.mdpi_barcode
  end
  def middle_shelf_notes=(notes)
    middle_shelf ||= CageShelf.new
    middle_shelf.notes = notes
  end
  def middle_shelf_notes
    middle_shelf.notes
  end

  def bottom_shelf_identifier=(id)
    bottom_shelf ||= CageShelf.new
    bottom_shelf.identifier = id
  end
  def bottom_shelf_identifier
    bottom_shelf.identifier
  end
  def bottom_shelf_mdpi_barcode=(barcode)
    bottom_shelf ||= CageShelf.new
    bottom_shelf.mdpi_barcode = barcode
  end
  def bottom_shelf_mdpi_barcode
    bottom_shelf.mdpi_barcode
  end
  def bottom_shelf_notes=(notes)
    bottom_shelf ||= CageShelf.new
    bottom_shelf.notes = notes
  end
  def bottom_shelf_notes
    bottom_shelf.notes
  end

  def can_by_shipped?
    total_physical_objects > 0 && top_shelf.can_ship? && middle_shelf.can_ship? && bottom_shelf.can_ship?
  end

  def total_physical_objects
    top_shelf.physical_objects.size + middle_shelf.physical_objects.size + bottom_shelf.physical_objects.size
  end

  def can_be_destroyed?
    top_shelf.physical_objects.size == 0 && middle_shelf.physical_objects.size == 0 && bottom_shelf.physical_objects.size == 0
  end

  def status
    shipped? ? "Shipped" : (ready_to_ship? ? 'Ready to Ship' : (can_by_shipped? ? 'Packing' : 'Empty'))
  end

  def to_xml(options)

  end

end
