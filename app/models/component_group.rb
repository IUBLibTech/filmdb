class ComponentGroup < ActiveRecord::Base
  belongs_to :title
  has_many :component_group_physical_objects
  has_many :physical_objects, through: :component_group_physical_objects

  def generations
    gen_set = Set.new
    physical_objects.each do |p|
      p.humanize_boolean_fields(PhysicalObject::GENERATION_FIELDS).split(',').each do |g|
        gen_set << g.strip
      end
    end
    gen_set.to_a.sort.join(', ').tr('"', '')
  end
end
