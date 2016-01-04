require 'test_helper'

class SimulationTest < ActiveSupport::TestCase
  test "create sim" do
    @sim = Simulation.create(name: "One", pressure: 200)
    assert_equal Simulation.first.pressure, 200
  end
end
