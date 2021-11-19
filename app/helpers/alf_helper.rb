module AlfHelper
	require 'net/scp'

	# 4th field after AL/MI is patron id, not email address, try to figure out which field is email address and use the IULMIA account that Andy monitors
	PULL_LINE_MDPI = "\"REQI\",\":IU_BARCODE\",\"IULMIA – MDPI\",\":TITLE\",\"AM\",\"AM\",\"\",\"\",\":EMAIL_ADDRESS\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"PHY\""
	PULL_LINE_WELLS = "\"REQI\",\":IU_BARCODE\",\"IULMIA – MDPI\",\":TITLE\",\"MI\",\"MI\",\"\",\"\",\":EMAIL_ADDRESS\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"PHY\""
	ALF = "ALF"
	WELLS_052 = "Wells"

	ALF_CFG = Rails.configuration.alf

	# this method is responsible for generating and upload the ALF system pull request file
	def push_pull_request(physical_objects, user)
		if physical_objects.length > 0
			upload_request_file(physical_objects, user)
		end
	end

	private
	# generates an array containing lines to be written to the ALF batch ingest file
	def upload_request_file_to_jackrabbit(pos, user)
		cedar = Rails.configuration.cedar
		upload_dir = cedar['upload_test_dir']
		logger.info("Target pull request directory: #{upload_dir}")
		file_contents = generate_pull_file_contents(pos, user)
		file = gen_file
		logger.info "Pull request file: #{file.path}"

		PullRequest.transaction do
			logger.info "File should contain #{file_contents.size} POs"
			if file_contents.size > 0
				File.write(file, file_contents.join("\n"))
				logger.info "#{file.path} created"
			end
			@pr = PullRequest.new(filename: file, file_contents: (file_contents.size > 0 ? file_contents.join("\n") : ''), requester: User.current_user_object)
			pos.each do |p|
				@pr.physical_object_pull_requests << PhysicalObjectPullRequest.new(physical_object_id: p.id, pull_request_id: @pr.id)
			end
			if file_contents.size > 0
				logger.info "connecting to #{cedar['host']} as #{cedar['username']}"
				Net::SSH.start(cedar['host'], cedar['username']) do |ssh|
					# when testing, make sure to use cedar['upload_test_dir'] - this is the sftp user account home directory
					# when ready to move into production testing change this to cedar['upload_dir'] - this is the ALF automated ingest directory
					success = ssh.scp.upload!(file, upload_dir)
					logger.info "scp.upload! returned #{success}"
				end
			end
			@pr.save!
			@pr
		end
	end

	def upload_pull_request_to_cedar(pos, user)
		file_contents = generate_pull_file_contents(pos, user)
		file = gen_file
		PullRequest.transaction do
			if file_contents.size > 0
				File.write(file, file_contents.join("\n"))
			end
			@pr = PullRequest.new(filename: file, file_contents: (file_contents.size > 0 ? file_contents.join("\n") : ''), requester: User.current_user_object)
			pos.each do |p|
				@pr.physical_object_pull_requests << PhysicalObjectPullRequest.new(physical_object_id: p.id, pull_request_id: @pr.id)
			end
			if file_contents.size > 0
				scp(file)
			end
			@pr.save!
			@pr
		end
	end

	# This method handles differentiating between scp'ing to cedar or jackrabbit depending on the alf.yml configuration file
	# and the Rails.env variable. The 'where' attribute in the config file determines whether uploads should be to cedar or
	# to jackrabbit. Only the rails production environment uploads to the actual GFS monitored directory. All other envs
	# upload to a test directory. Because the latest app migration runs Rails under the app user (and not myself), scp'ing
	# is handled differently depending on the destination server. scp'ing to cedar requires username/password whereas
	# scp'ing to jackrabbit is configured to use ssh pub/private keys for the app user.
	#
	# Once GFS production has moved to jackrabbit, this code can be condensed to handle only scp'ing to jackrabbit as the app
	# user
	def scp(file)
		if pull_request_where == "jackrabbit"
			Net::SSH.start(pull_request_host, pull_request_user) do |ssh|
				# when testing, make sure to use cedar['upload_test_dir'] - this is the sftp user account home directory
				# when ready to move into production testing change this to cedar['upload_dir'] - this is the ALF automated ingest directory
				success = ssh.scp.upload!(file, pull_request_upload_dir)
				logger.info "scp.upload! returned #{success}"
			end
		elsif pull_request_where == "cedar"
			Net::SCP.start(pull_request_host, pull_request_user, password: ALF_CFG['cedar_password']) do |scp|
				# when testing, make sure to use alf['upload_test_dir'] - this is the sftp user account home directory
				# when ready to move into production testing change this to alf['upload_dir'] - this is the ALF automated ingest directory
				success = scp.upload!(file, upload_dir)
				logger.info "scp.upload! returned #{success}"
			end
		else
			raise "Alf.yml does not have a valid 'where' value defined"
		end
	end

	def pull_request_upload_dir
		if pull_request_where == 'jackrabbit'
			Rails.env == "production" ? ALF_CFG['upload_dir'] : ALF_CFG['upload_test_dir']
		elsif pull_request_where == 'cedar'
			Rails.env == "production" ? ALF_CFG['cedar_upload_dir'] : ALF_CFG['cedar_upload_test_dir']
		end
	end
	def pull_request_user
		pull_request_where == 'jackrabbit' ? ALF_CFG['username'] : ALF_CFG['cedar_username']
	end
	def pull_request_host
		pull_request_where == 'jackrabbit' ? ALF_CFG['host'] : ALF_CFG["cedar_host"]
	end
	def pull_request_where
		ALF_CFG["where"]
	end

	def pulling_from?
		"#{pull_request_user}@#{pull_request_host} uploads to #{pull_request_upload_dir}"
	end

	def generate_pull_file_contents(physical_objects, user)
		str = []
		physical_objects.each do |po|
			if po.storage_location == WorkflowStatus::IN_STORAGE_INGESTED
				str << populate_line(po, user)
			end
		end
		str
	end

	def populate_line(po, user)
		pl = nil
		if po.active_component_group.deliver_to_alf?
			pl = PULL_LINE_MDPI
		else
			pl = PULL_LINE_WELLS
		end
		pl.gsub(':IU_BARCODE', po.iu_barcode.to_s).gsub(':TITLE', po.titles_text.truncate(20, omission: '')).gsub(':EMAIL_ADDRESS', user.email_address)
	end

	# generates a filename including path of the format <path>/<date>.<process_number>.webform.file where date is the
	# date the function is called and formated yyyymmdd, and process_number is a 0 padded 5 digit number repesenting the
	# (hopefully) id of the PullRequest the file will be associated with
	def gen_file
		file = File.join(Rails.root, 'tmp', "#{Date.today.strftime("%Y%m%d")}.#{gen_process_number}.webform.file")
		#"./tmp/#{Date.today.strftime("%Y%m%d")}.#{gen_process_number}.webform.file"
	end

	def gen_process_number
		id = PullRequest.maximum(:id)
		sprintf "%05d", (id.nil? ? 1 : id+1)
	end

	def test_upload_file
		pos = [PhysicalObject.find(PhysicalObject.pluck(:id).sample)]
		file = generate_pull_file_contents(pos, User.where(username" 'jaalbrec'").first)
		alf = Rails.configuration.alf
		Net::SCP.start(alf['host'], alf['username'], password: alf['passphrase']) do |scp|
			# when testing, make sure to use alf['upload_test_dir'] - this is the sftp user account home directory
			# when ready to move into production testing change this to alf['upload_dir'] - this is the ALF automated ingest directory
			puts "\n\n\n\n\nUploaded file: #{file}. Destination: #{alf['upload_test_dir']}\n\n\n\n\n"
			scp.upload!(file, upload_dir)
		end
	end

end
