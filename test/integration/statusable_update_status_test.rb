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
    @sims << SimulationJob.create(status: OSC::Machete::Status.queued, pbsid: "127")
  end

  def teardown
    # delete will avoid calling the destroy callbacks like "stop" i.e. qdel
    @sims.each(&:delete)
  end

  def test_update_models_on_index_request
    # 1. setup database and torque helper with jobs so that two jobs that are
    # cached as queued and running are actually running and passed
    OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).returns(OSC::Machete::Status.passed)

    # if a test below suddenly returns "Passed" instead of running it might be
    # because the signature of qstat or the arguments Job#status is passing to
    # these by default are different. If host: oakley is the default, then these
    # tests will break again. Better to have a different solution, such as a
    # custom TorqueHelper that implements qstat to accept pbsid and any number
    # of args so it can ignore the other keyword args...
    OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).with("125", host: nil).returns(OSC::Machete::Status.running)
    OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).with("127", host: nil).returns(OSC::Machete::Status.queued)

    # FIXME: move to a controller test?
    assert_equal @sims.length, SimulationJob.count, "Test database is not cleaned up after each test is run"

    # 2. when doing a get request, the active jobs should be updated
    get "/simulations"
    assert_response :success

    # 3. we verify the modifications to the active jobs took place
    assert_equal OSC::Machete::Status.passed, SimulationJob.where(pbsid: "123").first.status
    assert_equal OSC::Machete::Status.not_submitted, SimulationJob.where(pbsid: "124").first.status
    assert_equal OSC::Machete::Status.running, SimulationJob.where(pbsid: "125").first.status
    assert_equal OSC::Machete::Status.passed, SimulationJob.where(pbsid: "126").first.status
    assert_equal OSC::Machete::Status.queued, SimulationJob.where(pbsid: "127").first.status
  end
end

