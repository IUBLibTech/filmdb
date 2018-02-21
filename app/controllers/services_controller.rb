class ServicesController < ApplicationController
	require 'net/http'
	require 'uri'
	require 'memnon_digiprov_collector'
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :null_session
	include CagesHelper
	include BasicAuthenticationHelper

	before_action :authenticate, only: [:receive]
	skip_before_action :signed_in_user

	def receive
		logger.info "Someone has successfully authenticate with Filmdb services#receive: #{request.domain(2)}"
		bc = params[:bin_barcode]
		shelf = CageShelf.where(mdpi_barcode: bc.to_i).first
		if shelf.nil?
			@success = 'FAIURE'
			@reason = "Could not find cage shelf with MDPI Barcode: '#{bc}'"
		elsif !shelf.cage.shipped
			@success = 'FAILURE'
			@reason = "#{bc}'s cage has not been shipped to Memnon yet!"
		else
			begin
				PhysicalObject.transaction do
					shelf.physical_objects.each do |p|
						ws = WorkflowStatus.build_workflow_status(p.storage_location, p)
						p.workflow_statuses << ws
						p.save
					end
					if shelf.cage.all_shelves_returned?
						shelf.cage.update(shipped: false, ready_to_ship: false, returned: true)
					end
					@success = 'SUCCESS'
					shelf.update(returned: true)
				end
			rescue Exception => error
				@sucess = 'FAILURE'
				@reason = 'Unexpected failure in Filmdb updating physical objects to Returned to Storage - Please contact Andrew Albrecht'
				logger.debug $!
			end
			MemnonDigiprovCollector.new.collect_shelf_in_thread(shelf.id)
			)
		end
		data = {success: @success, error: (@reason.nil? ? '' : @reason)}
		render xml: data.to_xml(root: 'filmdbService')
	end


	def show_push_cage_to_pod_xml
		begin
			@cage = Cage.find(params[:cage_id])
			file_path = write_xml(@cage)
			@result = post_multipart(file_path)

			render text: @result.body

			# if parse_result
			# 	render 'services/successul_push_to_pod'
			# else
			# 	@message = "Something failed when exporting #{@cage.identifier} to POD\n#{@result}"
			# end
		rescue => e
			@error = e
			render 'failure'
		end
	end

	def test_basic_auth
		uri = URI.parse("https://pod-dev.mdpi.iu.edu/responses/objects/40000000334609/metadata/full")
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Get.new(uri.request_uri)
		request.basic_auth(Settings.pod_qc_user, Settings.pod_qc_pass)
		result = http.request(request)
		render text: result.to_yaml
	end

	private
	def post_multipart(file_path)
		uri = URI.parse(Rails.configuration.pod_batch_url)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Post.new(uri.path)
		request.basic_auth(Settings.pod_qc_user, Settings.pod_qc_pass)
		request.body = File.open(file_path).read

		# Send the request
		result = http.request(request)
		result
	end

	def parse_result
		@result.status == 200
	end


end
