module AlfHelper
	require 'net/scp'

	# 4th field after AL/MI is patron id, not email address, try to figure out which field is email address and use the IULMIA account that Andy monitors
	PULL_LINE_MDPI = "\"REQI\",\":IU_BARCODE\",\"IULMIA – MDPI\",\":TITLE\",\"RM\",\"DP\",\"\",\"iulmia@indiana.edu\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"PHY\""
	PULL_LINE_WELLS = "\"REQI\",\":IU_BARCODE\",\"IULMIA – MDPI\",\":TITLE\",\"RM\",\"MI\",\"\",\"iulmia@indiana.edu\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"PHY\""
	ALF = "ALF"
	WELLS_052 = "Wells"

	# this method is responsible for generating and upload the ALF system pull request file
	def push_pull_request(physical_objects)
		if physical_objects.length > 0
			upload_request_file(physical_objects)
		end
	end

	private
	# generates an array containing lines to be written to the ALF batch ingest file
	def upload_request_file(pos)
		file_contents = generate_pull_file_contents(pos)
		file_name = gen_file_name
		PullRequest.transaction do
			File.write(file_name, file_contents)
			pr = PullRequest.new(filename: file_name,file_contents: file_contents)
			pos.each do |p|
				pr.physical_object_pull_requests << PhysicalObjectPullRequest.new(physical_object_id: p.id, pull_request_id: pr.id)
			end
			cedar = Rails.configuration.cedar
			Net::SCP.start(cedar['host'], cedar['username'], password: cedar['password']) do |scp|
				# FIXME: when ready to move into production testing change this to cedar['upload_dir']
				scp.upload!(file_name, "#{cedar['upload_test_dir']}")
			end
			pr.save!
		end
	end

	def generate_pull_file_contents(physical_objects)
		str = []
		physical_objects.each do |po|
			str << populate_line(po)
		end
		str.join("\n")
	end

	def populate_line(po)
		pl = nil
		if po.active_component_group.is_reformating?
			pl = PULL_LINE_MDPI
		else
			pl = PULL_LINE_WELLS
		end
		pl.gsub(':IU_BARCODE', po.iu_barcode.to_s).gsub(':TITLE', po.titles_text.truncate(20, omission: ''))
	end

	# generates a filename including path of the format <path>/<date>.<process_number>.webform.file where date is the
	# date the function is called and formated yyyymmdd, and process_number is a 0 padded 5 digit number repesenting the
	# (hopefully) id of the PullRequest the file will be associated with
	def gen_file_name
		"./tmp/#{Date.today.strftime("%Y%m%d")}.#{gen_process_number}.webform.file"
	end

	def gen_process_number
		id = PullRequest.maximum(:id)
		sprintf "%05d", (id.nil? ? 1 : id+1)
	end

end
