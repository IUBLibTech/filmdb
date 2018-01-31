class ComponentGroup < ActiveRecord::Base
  belongs_to :title
  has_many :component_group_physical_objects
  has_many :physical_objects, through: :component_group_physical_objects

  BEST_COPY_WELLS = 'Best Copy (Wells)'
  BEST_COPY_MDPI_WELLS = 'Best Copy (MDPI - WELLS)'
  BEST_COPY_ALF = 'Best Copy (MDPI)'
  REFORMATTING_MDPI = 'Reformatting (MDPI)'
  CATALOG_WELLS = "Cataloging"
  DIGITIZATION_WELLS = "Digitization"
  EVALUATION_WELLS = "Evaluation"
  EXHIBITION_WELLS = "Exhibition"
  RESEARCHER_WELLS = "Researcher"
  TEACHING_WELLS = "Teaching"

  ALF_TYPES = [BEST_COPY_ALF, REFORMATTING_MDPI]
  BEST_COPY_TYPES = [BEST_COPY_ALF, BEST_COPY_MDPI_WELLS]

  MDPI_GROUP_TYPES = [BEST_COPY_ALF, BEST_COPY_MDPI_WELLS, REFORMATTING_MDPI]
  ALF_DELIVERY_GROUPS = [BEST_COPY_ALF, REFORMATTING_MDPI]
  WELLS_DELIVERY_GROUPS = [BEST_COPY_MDPI_WELLS, CATALOG_WELLS, DIGITIZATION_WELLS,
                           EVALUATION_WELLS, EXHIBITION_WELLS, RESEARCHER_WELLS, TEACHING_WELLS]

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
      unless p.current_workflow_status.can_be_pulled?
        return false
      end
    end
    true
  end

  def deliver_to_alf?
    ALF_DELIVERY_GROUPS.include?(group_type)
  end

  def deliver_to_wells?
   WELLS_DELIVERY_GROUPS.include?(group_type)
  end

  def is_reformating?
	  group_type.include?('Reformatting') || group_type.include?('Best Copy')
  end

  def all_present?
	  all = true
    all &= (physical_objects.first.waiting_active_component_group_members? == false) if physical_objects.size > 0
    all
  end

  def whose_workflow
    MDPI_GROUP_TYPES.include?(group_type) ? WorkflowStatus::MDPI : WorkflowStatus::IULMIA
  end

	def in_active_workflow?
    # noinspection RubyResolve
    physical_objects.any?{|p| p.active_component_group == self}
	end

end
