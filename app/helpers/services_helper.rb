module ServicesHelper
	require 'net/http'
	require 'uri'
	include CagesHelper

	def push_cage_to_pod(cage)
		file_path = write_xml(cage)
		return post_multipart(file_path)
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

end