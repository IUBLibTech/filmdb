class PodObject< ActiveRecord::Base
  self.abstract_class = true
  establish_connection POD_DB
end