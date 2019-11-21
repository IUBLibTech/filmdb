class VideoParser
  include DateHelper
  include PhysicalObjectsHelper
  include ParserHelper
  require 'csv'
  require 'manual_roll_back_error'

  # the column headers that spreadsheets should contain for Videos - only the 5 metadata fields required to create a physical object
  # are required in the spreadsheet headers, but if optional fields are supplied, they must conform to this vocabulary
  COLUMN_HEADERS = PO_HEADERS + [
      'Title', 'Duration', 'Series Name', 'Version', 'Gauge', 'Generation', 'Original Identifier', 'Reel Number',
      'Multiple Items in Can', 'Can Size', 'Footage', 'Edge Code Date', 'Base', 'Stock', 'Picture Type', 'Frame Rate',
      'Color', 'Aspect Ratio', 'Sound', 'Captions or Subtitles', 'Captions or Subtitles Notes', 'Sound Format Type',
      'Sound Content Type', 'Sound Field', 'Dialog Language', 'Captions or Subtitles Language', 'AD Strip', 'Shrinkage',
      'Mold', 'Missing Footage', 'Creator', 'Publisher', 'Genre', 'Form', 'Subject', 'Alternative Title',
      'Series Production Number', 'Series Part', 'Date', 'Location', 'Title Summary', 'Title Notes', 'Name Authority',
      'Generation Notes'
  ]

end