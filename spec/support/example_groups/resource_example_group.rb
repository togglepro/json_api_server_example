module ResourceExampleGroup
  extend ActiveSupport::Concern

  included do
    require "jsonapi/resource_serializer"
    let :serializer do
      JSONAPI::ResourceSerializer.new(described_class)
    end
    let :model do
      FactoryGirl.build_stubbed(
        described_class._model_class.model_name.element,
        id: 1001
      )
    end
    let :resource do
      described_class.new(model)
    end
    let :serialized_hash do
      serializer.serialize_to_hash(resource)
    end
  end

  RSpec.configure do |config|
    config.include(self, type: :resource, file_path: %r(spec/resources))
  end
end
