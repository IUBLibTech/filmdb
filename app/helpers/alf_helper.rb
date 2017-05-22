module AlfHelper

	def pull_request(componentGroupIdArray)
		pos = []
		componentGroupIdArray.each do |cgId|
			cg = ComponentGroup.find(cgId)
			if cg.group_type != 'Reformating'
				raise PullRequestError, "Cannot send non 'Reformating' ComponentGroup for digitization"
			else
				cg.physical_objects.each do |p|
					pos << p
				end
			end
		end
		contents = generate_pull_file_contents(pos)
		contents = contents.join("\n")
		begin
			PullRequest.transaction do
				f = File.new(gen_file_name('tmp/'), "wb")
				pr = PullRequest.new(created_by_id: User.current_user_object.id, filename: File.basename(f.path), file_contents: contents)
				pr.save
				pos.each do |p|
					PhysicalObjectPullRequest.new(physical_object_id: p.id, pull_request_id: pr.id).save
					p.workflow_statuses << WorkflowStatus.new(physical_object_id: p.id, workflow_status_template_id: WorkflowStatusTemplate.order(:sort_order).first.id)
					p.save
				end
				b = f.write(contents)
				debugger
				f.close();
				deposit_pull_fill(f)
				return "success"
			end
		rescue => e
			puts e.message
			puts e.backtrace
			return "failure"
		end
	end

	private
	# generates an array containing lines to be written to the ALF batch ingest file
	def generate_pull_file_contents(list)
		str = []
		list.each do |po|
			str << "\"REQI\",\"#{po.iu_barcode}\",\" IULMIA – MDPI\",\"#{po.titles_text.truncate(20, omission: '')}\",\"RM\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"PHY\""
		end
		str
	end

	# does the work of writting the specified file to the ALF batch ingest directory
	def deposit_pull_fill(file)
		# FIXME: implement when we have the specifics
	end

	# generates a filename including path of the format <path>/<date>.<process_number>.webform.file where date is the
	# date the function is called and formated yyyymmdd, and process_number is a 0 padded 5 digit number repesenting the
	# (hopefully) id of the PullRequest the file will be associated with
	def gen_file_name(path)
		"#{path}/#{Date.today.strftime("%Y%m%d")}.#{gen_process_number}.webform.file"
	end

	def gen_process_number
		id = PullRequest.maximum(:id)
		sprintf "%05d", (id.nil? ? 1 : id+1)
	end

end
