class TitleCreatorPublishersUnknownToTbd < ActiveRecord::Migration
  def change
    TitlePublisher.where(publisher_type: 'Unknown').update_all(publisher_type: 'TBD')
    TitleCreator.where(role: 'Unknown').update_all(role: 'TBD')
  end
end
