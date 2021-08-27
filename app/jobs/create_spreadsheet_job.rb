class PrepareSpreadsheetJob < ApplicationJob
  queue_as :default

  def perform(username, title_text)
    
  end
end