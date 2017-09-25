class ComponentGroup < ActiveRecord::Base
  belongs_to :title
  has_many :component_group_physical_objects
  has_many :physical_objects, through: :component_group_physical_objects

  MDPI_GROUP_TYPES = ['Best Copy (MDPI)', 'Reformatting (MDPI)', 'Reformatting Replacement (MDPI)']
  BEST_COPY_WELLS = 'Best Copy (Wells)'
  BEST_COPY_ALF = 'Best Copy (MDPI)'
  BEST_COPY_TYPES = [BEST_COPY_ALF, BEST_COPY_WELLS]


  COLOR_SPACE_LIN_10 = 'Linear 10 bit'
  COLOR_SPACE_LIN_16 = 'Linear 16 bit'
  COLOR_SPACE_LOG_10 = 'Logarithmic 10 bit'
  COLOR_SPACES = [COLOR_SPACE_LOG_10, COLOR_SPACE_LIN_10, COLOR_SPACE_LIN_16]


  def generations
    gen_set = Set.new
    physical_objects.each do |p|
      p.humanize_boolean_fields(PhysicalObject::GENERATION_FIELDS).split(',').each do |g|
        gen_set << g.strip
      end
    end
    gen_set.to_a.sort.join(', ').tr('"', '')
  end

  def can_be_pulled?
    physical_objects.each do |p|
      if !p.current_workflow_status.can_be_pulled?
        return false
      end
    end
    true
  end

  def is_mdpi_workflow?
	  # FIXME: this needs to be more robust...
    group_type.include? 'MDPI'
  end

  def is_reformating?
	  group_type.include? 'Reformatting'
  end

  def all_present?
	  all = true
	  if physical_objects.size > 0
		  all &= (physical_objects.first.waiting_active_component_group_members? == false)
	  end
  end

  def whose_workflow
    MDPI_GROUP_TYPES.include?(group_type) ? WorkflowStatus::MDPI : WorkflowStatus::IULMIA
  end

  def alf_delivery?

  end

  def wells_delivery?

  end

end
