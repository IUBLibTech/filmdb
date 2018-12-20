json.array!(@collection_inventory_configurations) do |collection_inventory_configuration|
  json.extract! collection_inventory_configuration, :id
  json.url collection_inventory_configuration_url(collection_inventory_configuration, format: :json)
end
