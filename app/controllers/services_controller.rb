class ServicesController < ApplicationController
	require 'nokogiri'

	def receive
		begin
			xml = request.body.read
			doc = Nokogiri::XML(xml).remove_namespaces!
			puts doc
		end
	end

end
