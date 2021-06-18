class ConvertAvalonUrlToStreamingUrl < ActiveRecord::Migration
  require 'net/http'
  require 'net/https'
  def up
    titles = Title.all
    titles.each_with_index  do |t, i|
      puts "Updating stream url for title #{i+1} of #{titles.size}"
      if t.digitized?
        a_url = t.avalon_url
        puts "\t#{a_url}"
        t.update_attributes(stream_url: a_url[:url]) unless a_url[:url].blank?
      end
    end
  end
  def down
    Title.all.update_attributes(stream_url: nil)
  end
end
