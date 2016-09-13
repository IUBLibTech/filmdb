json.array!(@series_titles) do |series_title|
  json.extract! series_title, :id
  json.url series_title_url(series_title, format: :json)
end
