module TitlesHelper

	# attempts to merge all mergees into the master title record - physical objects are reassigned, all non-duplicate creator,
	# publisher, date, genre, form, etc data is also moved over to the master record. Currently, titles that are in active
	# workflow will not be merged. This method will return a array of any titles not merged
	def title_merge(master, mergees)
		failed = []
		fix_component_groups(master, mergees)
		mergees.each do |m|

			if m.in_active_workflow?
				failed << m
				next
			end

			m.series_id = master.series_id

			if master.series_part.blank?
				master.series_part = m.series_part
			end

			# if master.summary is nil then += will fail as there is no += operator or nil...
			master.summary = '' if master.summary.blank?
			unless m.summary.blank?
				master.summary += " | #{m.summary}"
			end
			unless m.series_part.blank?
				master.series_part += (master.series_part.blank? ? m.series_part : " | #{m.series_part}")
			end
			unless m.notes.blank?
				master.notes += (master.notes.blank? ? m.notes : " | #{m.notes}")
			end
			unless m.subject.blank?
				master.subject += (master.subject.blank? ? m.subject : " | #{m.subject}")
			end

			m.title_original_identifiers.each do |toi|
				unless master.title_original_identifiers.include? toi
					master.title_original_identifiers << toi
				end
			end
			m.title_creators.each do |tc|
				unless master.title_creators.collect.include? tc
					master.title_creators << tc
				end
			end
			m.title_publishers.each do |tp|
				unless master.title_publishers.collect.include? tp
					master.title_publishers << tp
				end
			end
			m.title_forms.each do |tf|
				unless master.title_forms.collect.include? tf
					master.title_forms << tf
				end
			end
			m.title_genres.each do |tg|
				unless master.title_genres.collect.include? tg
					master.title_genres << tg
				end
			end
			m.title_dates.each do |td|
				unless master.title_dates.collect.include? td
					master.title_dates << td
				end
			end
			m.title_locations.each do |tl|
				unless master.title_locations.collect.include? tl
					master.title_locations << tl
				end
			end
			PhysicalObjectTitle.where(title_id: m.id).update_all(title_id: master.id)
			m.delete
		end
		failed
	end

	def fix_component_groups(master, mergees)
		ms = "This Component Group was created in a differebt title that was merged into this record. It may no longer be relevant."
		mergees.each do |t|
			t.component_groups.each do |cg|
				cg.title_id = master.id
				cg.group_summary = (cg.group_summary.blank? ? ms : " | #{ms}" )
				cg.save
			end
		end
	end

end
