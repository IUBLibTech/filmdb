json.array!(@component_groups) do |component_group|
  json.extract! component_group, :id
  json.url component_group_url(component_group, format: :json)
end
