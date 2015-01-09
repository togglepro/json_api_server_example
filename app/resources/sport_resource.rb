require "jsonapi/resource"

class SportResource < JSONAPI::Resource
  attributes :id, :name
end
