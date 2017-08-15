class ServicesController < ApplicationController
	require 'net/http'
	require 'uri'
	include CagesHelper
	include BasicAuthenticationHelper

	before_action :authenticate, only: [:receive]
	skip_before_action :signed_in_user

	def receive
		logger.info "Someone has successfully authenticate with Filmdb services#receive: #{request.domain(2)}"
		@success = true
		@msg = "Filmdb received the batch update"
		render template: 'services/receive', layout: false
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
