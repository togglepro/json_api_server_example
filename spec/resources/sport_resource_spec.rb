require "rails_helper"

describe SportResource do
  let :expected_serialized_hash do
    {
      "sports" => {
        "id" => 1001,
        "name" => "Basketball"
      }
    }
  end
  it "serializes the sport into the correct JSON format" do
    expect(serialized_hash).to eq(expected_serialized_hash)
  end
end
