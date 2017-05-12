module ServicesHelper
	require 'net/http'
	require 'uri'
	require 'mime/types'
	include CagesHelper

	def push_cage_to_pod(cage_id)
		@cage = Cage.find(cage_id)
		file_path = write_xml(@cage)
		puts "\n\n\nWrote the XML FILE!!!\n\n\n"
		post_multipart(file_path)
	end

	private
	# taken from https://coderwall.com/p/c-mu-a/http-posts-in-ruby
	def post_multipart(file_path)
		uri = URI.parse(Rails.configuration.pod_batch_url)

		boundary = "AaB03x"
		header = {"Content-Type": "multipart/form-data; boundary=#{boundary}"}
		file = "test_file.xml"

		# We're going to compile all the parts of the body into an array, then join them into one single string
		# This method reads the given file into memory all at once, thus it might not work well for large files
		post_body = []

		# Add the file Data
		post_body << "--#{boundary}\r\n"
		post_body << "Content-Disposition: form-data; name=\"user[][image]\"; filename=\"#{File.basename(file)}\"\r\n"
		post_body << "Content-Type: #{MIME::Types.type_for(file)}\r\n\r\n"
		post_body << File.read(file_path)

		# Create the HTTP objects
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Post.new(uri.request_uri, header)
		request.body = post_body.join

		# Send the request
		puts "\n\n\nAbout to POST to localhost\n\n\n"
		result = http.request(request)
		puts "\n\n\nPOSTed to localhost #{result}\n\n\n"
		result
	end


end
