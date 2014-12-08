# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  data       :json
#  game_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require "test_helper"

describe Event do
  let(:event) { Event.new }

  it "must be valid" do
    event.must_be :valid?
  end
end