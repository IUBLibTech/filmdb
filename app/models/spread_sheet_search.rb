class SpreadSheetSearch < ActiveRecord::Base
  require "axlsx"
  belongs_to :user
  belongs_to :collection

  # we can't know what percent total job runtime a query has until after the job is complete. This value is used to 'edtimate'
  # where we are in the job after the query completes. Eventually, we'll look at statistics to find a better estimate for
  # the average of query runtimes
  ARBITRARY_QUERY_PERCENT = 10

  def logger
    @@my_logger ||= Logger.new("#{Rails.root}/log/spreadsheet_job_log.log")
  end

  def username
    user.username
  end

  def collection_name
    collection&.name
  end

  def in_progress?
    completed.nil? && percent_complete < 100
  end

  def filename
    file_location.gsub('tmp/', '')
  end

  def create
    begin
      # the query portion of the download begins first with logging and ActiveModel update of the saved record
      @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "Creating new SpreadSheetSearch for #{user.username} with id: #{id}"
      q = run_query
      @end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      elapsed = @end_time - @start_time
      puts "Query for spreadsheet id: #{id} took #{elapsed} seconds to complete"
      # arbitrarily choose "10%" completion after the query runs to indicate some work has been done
      update_attributes(query_runtime: elapsed, percent_complete: 10)

      # now the looooong part - generating the spreadsheet
      @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts"Starting spreadsheet generation for id: #{id}"
      ss = generate_spreadsheet(q)
      # save the file
      file_location = "tmp/#{username}_#{id.to_s.rjust(4, "0")}.xlsx"
      if save_spreadsheet_to_file(ss, file_location)
        @end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        update_attributes(completed: true, percent_complete: 100, file_location: file_location, spreadsheet_runtime: @end_time - @start_time)
      else
        raise "Failed to save the spreadsheet file to #{file_location}"
      end
    rescue => e
      # if we don't catch -ALL- exceptions here, the delayed_job will fail and attempt to re-run at a later time. We also
      # want the stack trace stored with the SpreadSheetSearch object along with doing some book keeping to indicate the
      # spreadsheet generation failed
      error_msg = e.message
      error_msg << e.backtrace.join("\n")
      puts error_msg
      update_attributes(completed: false, error_message: error_msg)
    end
  end
  #handle_asynchronously :create

  private
  def run_query
    titles = title_text.blank? ? Title.all : Title.where("title_text like '%#{title_text}%'")
    unless digitized_status == 'all'
      if digitized_status == "not_digitized"
        titles = titles.where("titles.stream_url is null OR titles.stream_url = ''")
      elsif digitized_status == "digitized"
        titles = titles.where("titles.stream_url is not null AND titles.stream_url != ''")
      end
    end
    titles = titles.where("titles.summary LIKE ?", "%#{summary_text}%") unless summary_text.blank?
    titles = titles.where("titles.subject LIKE ?", "%#{subject_text}%") unless subject_text.blank?

    titles = titles.joins(:series).includes(:series).where("series.title LIKE ?", "%#{series_name}%") unless series_name.blank?

    unless date_text.blank?
      dates = date_text.gsub(' ', '').split('-')
      if dates.size == 1
        titles = titles.joins(:title_dates).includes(:title_dates).where(
          "title_dates.end_date is null AND year(title_dates.start_date) = ? OR "+
            "(title_dates.end_date is not null AND year(title_dates.start_date) <= ? AND year(title_dates.end_date) >= ?)", dates[0], dates[0], dates[0])
      else
        titles = titles.joins(:title_dates).includes(:title_dates).where(
          "(title_dates.end_date is null AND year(title_dates.start_date) >= ? AND year(title_dates.start_date) <= ?  OR "+
            "(title_dates.end_date is not null AND "+
            "((year(title_dates.start_date) >= ? AND year(title_dates.start_date) <= ?) OR "+
            "(year(title_dates.end_date) >= ? AND year(title_dates.end_date) <= ? OR "+
            "(year(title_dates.start_date) < ? AND year(title_dates.end_date) > ?)))",
          dates[0], dates[1], dates[0], dates[1], dates[0], dates[1], dates[0], dates[1]
        )
      end
    end
    titles = titles.joins(:title_publishers).includes(:title_publishers).where("title_publishers.name LIKE ?", "%#{publisher_text}%") unless publisher_text.blank?
    titles = titles.joins(:title_creators).inlcudes(:title_creators).where("title_creators.name like ?", "%#{creator_text}%") unless creator_text.blank?
    titles = titles.joins(:title_locations).includes(:title_locations).where("title_locations.location ?", "%#{location_text}%") unless location_text.blank?
    if collection_id == 0
      titles = titles.joins(:physical_objects).includes(:physical_objects)
    else
      titles = titles.joins(:physical_objects).includes(:physical_objects).where("physical_objects.collection_id = ?", collection_id) unless collection_id == 0
    end
    titles
  end

  def generate_spreadsheet(results)
    x = Axlsx::Package.new
    wb = x.workbook
    films = wb.add_worksheet(name: "Films")
    videos = wb.add_worksheet(name: "Videos")
    recorded_sounds = wb.add_worksheet(name: "Recorded Sounds")
    Film.write_xlsx_header_row( films)
    Video.write_xlsx_header_row( videos )
    RecordedSound.write_xlsx_header_row( recorded_sounds )
    total = results.size.to_f
    results.each_with_index do |t, i|
      # we want to avoid excessive writes to the database while updating the completion status of the job
      # so only write when -percent_complete- state jumps forward by 5%. Remember, percent_complete is the
      # total JOB completion state: at this point in code, the time taken to run the query AND where we are in spreadsheet
      # generation. To get that value we have to do some ugly math...
      #
      # We defined a guesstimated fixed percentage of a job's runtime for the query portion (because that can't be known
      # ahead of time): ARBITRARY_QUERY_RUNTIME. The percentage of time a job takes on SS generation is 100 (percent)
      # minus ARBITRARY_QUERY_RUNTIME. To get total percent completion of the JOB:
      # ARBITRARY_QUERY_RUNTIME + ((100 - ARBITRARY_QUERY_RUNTIME) * <what percentage of titles we've process so far>)
      title_percent = i / total
      total_percent = ARBITRARY_QUERY_PERCENT + ((100 - ARBITRARY_QUERY_PERCENT) * title_percent)
      if total_percent >= percent_complete + 5
        puts "Completed another 5% of spreadsheet id: #{id}, now #{total_percent}% complete."
        update_attributes(percent_complete: total_percent.to_i)
      end
      t.physical_objects.each do |po|
        if po.specific.medium == "Film"
          @worksheet = films
        elsif po.specific.medium == "Video"
          @worksheet = videos
        elsif po.specific.medium == "Recorded Sound"
          @worksheet = recorded_sounds
        else
          raise "Unsupported spreadsheet download medium: #{po.specific.medium}"
        end
        po.specific.write_xlsx_row(t, @worksheet)
      end
    end
    x
  end

  def save_spreadsheet_to_file(ss, filename)
    ss.serialize(filename)
  end
end
