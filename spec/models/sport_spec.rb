require "rails_helper"

RSpec.describe Sport, type: :model do
  it { is_expected.to have_attribute :name }
end
