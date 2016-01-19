require 'test_helper'

class StatusableUpdateStatusTest < ActionDispatch::IntegrationTest
  fixtures :all

  def setup
    # FIXME: better to create simulations from doing a request to post a new sim
    @sims = []
    @sims << SimulationJob.create(status: OSC::Machete::Status.passed, pbsid: "123")
    @sims << SimulationJob.create(status: OSC::Machete::Status.not_submitted, pbsid: "124")
    @sims << SimulationJob.create(status: OSC::Machete::Status.queued, pbsid: "125")
    @sims << SimulationJob.create(status: OSC::Machete::Status.running, pbsid: "126")
  end

  def teardown
    @sims.each(&:destroy)
  end

  def test_m
    assert_equal 4, SimulationJob.count, "Test database is not cleaned up after each test is run"
  end

  def test_update_models_on_index_request
    # 1. setup database and torque helper with jobs so that two jobs that are
    # cached as queued and running are actually running and passed
    OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).returns(OSC::Machete::Status.passed)
    OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).with("125").returns(OSC::Machete::Status.running)

    # FIXME: move to a controller test?
    assert_equal 4, SimulationJob.count

    # 2. when doing a get request, the active jobs should be updated
    get "/simulations"
    assert_response :success

    # 3. we verify the modifications to the active jobs took place
    assert_equal OSC::Machete::Status.passed, SimulationJob.where(pbsid: "123").first.status
    assert_equal OSC::Machete::Status.not_submitted, SimulationJob.where(pbsid: "124").first.status
    assert_equal OSC::Machete::Status.running, SimulationJob.where(pbsid: "125").first.status
    assert_equal OSC::Machete::Status.passed, SimulationJob.where(pbsid: "126").first.status
  end
end

