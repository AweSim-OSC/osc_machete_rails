require 'test_helper'

class StatusableUpdateStatusTest < ActionDispatch::IntegrationTest
  fixtures :all

  def test_m
    SimulationJob.create status: OSC::Machete::Status.completed, pbsid: "123.osc.edu"
    assert_equal 1, SimulationJob.count
  end

  def test_update_models_on_index_request
    # 1. setup database and torque helper with jobs so that two jobs that are
    # cached as queued and running are actually running and completed
    OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).returns(OSC::Machete::Status.completed)
    OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).with("125").returns(OSC::Machete::Status.running)

    # FIXME: move to a controller test?
    # FIXME: better to create simulations from doing a request to post a new sim
    SimulationJob.create status: OSC::Machete::Status.completed, pbsid: "123"
    SimulationJob.create status: OSC::Machete::Status.not_submitted, pbsid: "124"
    SimulationJob.create status: OSC::Machete::Status.queued, pbsid: "125"
    SimulationJob.create status: OSC::Machete::Status.running, pbsid: "126"
    assert_equal 4, SimulationJob.count

    # 2. when doing a get request, the active jobs should be updated
    get "/simulations"
    assert_response :success

    # 3. we verify the modifications to the active jobs took place
    assert_equal OSC::Machete::Status.completed, SimulationJob.where(pbsid: "123").first.status
    assert_equal OSC::Machete::Status.not_submitted, SimulationJob.where(pbsid: "124").first.status
    assert_equal OSC::Machete::Status.running, SimulationJob.where(pbsid: "125").first.status
    assert_equal OSC::Machete::Status.completed, SimulationJob.where(pbsid: "126").first.status
  end
end

