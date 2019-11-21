module ParserHelper
  # the column headers that spreadsheets should contain - only the 5 metadata fields required to create a physical object
  # are required in the spreadsheet headers, but if optional fields are supplied, they must conform to this vocabulary
  PO_HEADERS = [
      'Media Type', 'Medium', 'Unit', 'Collection', 'Current Location', 'IU Barcode', 'MDPI Barcode', 'IUCat Title No.',
      'Format Notes', 'Overall Condition', 'Research Value', 'Overall Condition Notes', 'Condition Type', 'Miscellaneous Condition Type', 'Conservation Actions',
      'Accompanying Documentation', 'Created By', 'Email Address', 'Research Value Notes', 'Date Created',
      'Accompanying Documentation Location', 'ALF Shelf Location', 'Catalog Key'
  ]
  # The indexes in PO_HEADERS at which each attribute occurs
  MEDIA_TYPE, MEDIUM, UNIT, COLLECTION, CURRENT_LOCATION, IU_BARCODE, MDPI_BARCODE, IUCAT_TITLE_NO = 0,1,2,3,4,5,6,7
  FORMAT_NOTES, OVERALL_CONDITION, RESEARCH_VALUE, OVERALL_CONDITION_NOTES = 8,9,10,11
  CONDITION_TYPE, MISCELLANEOUS_CONDITION_TYPE, CONSERVATION_ACTIONS = 12,13,14
  ACCOMPANYING_DOCUMENTATION, CREATED_BY, EMAIL_ADDRESS, RESEARCH_VALUE_NOTES, DATE_CREATED = 15,16,17,18,19
  ACCOMPANYING_DOCUMENTATION_LOCATION, ALF_SHELF_LOCATION, CATALOG_KEY = 20,21,22

  # regexes for parsing
  CONDITION_PATTERN = /([a-zA-z]+) \(([\d])\)/
  NAME_ROLE_PATTERN = /^([a-zA-Z ]+) \(([a-zA-z ]+)\)$/

  # Delimiter used in columns with multiple values present
  DELIMITER = ' ; '

end
