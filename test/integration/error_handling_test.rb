require 'test_helper'
require 'awesim_rails'

class ErrorHandlingTest < ActionDispatch::IntegrationTest

  # these tests are for 

  def setup
    # defaults
    OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).raises(PBS::Error, "The system is down!")
    OSC::Machete::TorqueHelper.any_instance.stubs(:qdel).raises(PBS::Error, "The system is down!")
    OSC::Machete::TorqueHelper.any_instance.stubs(:qsub).raises(PBS::Error, "The system is down!")

    # FIXME: better to create simulations from doing a request to post a new sim
    @sim = Simulation.create
    @tmpdir = Dir.mktmpdir
    @empty_template = Pathname.new(@tmpdir + "/template")
    FileUtils.mkdir(@empty_template.to_s)
    @empty_template = @empty_template.realpath

    ::AwesimRails.dataroot = Pathname.new(@tmpdir)
  end

  def teardown
    @sim.delete
    FileUtils.rm_rf @tmpdir
  end

  def simulations_dir_empty?
    Dir[@tmpdir+'/*'].empty? || Dir[@tmpdir+'/simulations/*'].empty?
  end

  def test_handle_missing_script_error_on_submit
    # stub to an empty template to trigger ScriptMissingError
    Simulation.any_instance.stubs(:staging_template_dir).returns(@empty_template)

    # sanity check
    assert_equal 1, Simulation.count, "Sanity check failed"
    assert simulations_dir_empty?, "Sanity check failed"
    assert @empty_template.directory?, "Sanity check failed"

    # now we should be able to try to submit the simulation, that needs main.sh but doesn't have it
    put "/simulations/#{@sim.id}/submit"

    assert_response 500

    # verify an error message was attached to the simulation object
    assert assigns(:simulation).errors.to_a.any?
    assert assigns(:simulation).errors.to_a.first =~ /ScriptMissingError/, "Should have thrown ScriptMissingError"
    assert simulations_dir_empty?, 'If submitting a simulation fails, the staged directory should be deleted.'

    Simulation.any_instance.unstub(:staging_template_dir)
  end

  def test_handle_pbs_error_on_submit
    # sanity check
    assert_equal 1, Simulation.count, "Sanity check failed"
    assert simulations_dir_empty?, "Sanity check failed"

    # now we should be able to try to submit a simulation
    put "/simulations/#{@sim.id}/submit"

    assert_response 500

    # verify an error message was attached to the simulation object
    assert assigns(:simulation).errors.to_a.any?
    assert assigns(:simulation).errors.to_a.first =~ /PBS::Error/, "Should have thrown PBS::Error"
    assert simulations_dir_empty?, 'If submitting a simulation fails, the staged directory should be deleted.'
  end

  def test_handle_qstat_error_on_submit
    OSC::Machete::TorqueHelper.any_instance.stubs(:qsub).returns("123456.oakley.osc.edu")

    put "/simulations/#{@sim.id}/submit"

    assert_response :found

    # submission succeeded, but qdel failed!
    assert Simulation.find(@sim.id).status.queued?
    assert Simulation.find(@sim.id).simulation_jobs.count == 1

    # after submission succeeds, qstat-ing fails, we must handle it gracefully
    OSC::Machete::TorqueHelper.any_instance.stubs(:qsub).raises(PBS::Error, "The system is down!")
  end


  def test_update_status_handles_qstat_error
    @s1 = SimulationJob.create status: OSC::Machete::Status.queued, pbsid: "1"
    @s2 = SimulationJob.create status: OSC::Machete::Status.queued, pbsid: "2"
    @s3 = SimulationJob.create status: OSC::Machete::Status.queued, pbsid: "3"

    # new
    OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).with("1", any_parameters).returns(OSC::Machete::Status.running)
    OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).with("2", any_parameters).raises(PBS::Error, "The system is down!")
    OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).with("3", any_parameters).returns(OSC::Machete::Status.passed)

    get "/simulations"

    # @s2 is queued and qstat will throw an error so it should just stay queued
    # the others should be updated
    assert_equal OSC::Machete::Status.running, SimulationJob.find(@s1.id).status
    assert_equal OSC::Machete::Status.queued, SimulationJob.find(@s2.id).status
    assert_equal OSC::Machete::Status.passed, SimulationJob.find(@s3.id).status

    @s1.delete
    @s2.delete
    @s3.delete

    # original
    OSC::Machete::TorqueHelper.any_instance.unstub(:qstat)
    OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).raises(PBS::Error, "The system is down!")
  end


  def test_delete_running_simulation_fails
    OSC::Machete::TorqueHelper.any_instance.stubs(:qsub).returns("123456.oakley.osc.edu")
    OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).returns(OSC::Machete::Status.running)

    put "/simulations/#{@sim.id}/submit"

    assert_response :found

    # verify we its running now
    assert Simulation.find(@sim.id).status.running?
    assert Simulation.find(@sim.id).simulation_jobs.count == 1

    @job = @sim.simulation_jobs.first

    # delete a running simulation
    delete "/simulations/#{@sim.id}"

    # delete threw error, so nothing should have happened
    assert SimulationJob.find(@job.id).status.running?
    assert Simulation.find(@sim.id).status.running?
    assert Simulation.find(@sim.id).simulation_jobs.count == 1

    assert_response 500

    # verify an error message was attached to the simulation object
    assert assigns(:simulation).errors.to_a.any?
    assert assigns(:simulation).errors.to_a.first =~ /PBS::Error/, "Should have thrown PBS::Error"

    OSC::Machete::TorqueHelper.any_instance.stubs(:qdel).returns(nil)

    # delete simulation now that "the system is fixed"
    delete "/simulations/#{@sim.id}"

    # delete threw error, so nothing should have happened
    assert ! SimulationJob.where(id: @job.id).any?
    assert ! Simulation.where(id: @sim.id).any?

    assert_response :found

    # after submission succeeds, qstat-ing fails, we must handle it gracefully
    OSC::Machete::TorqueHelper.any_instance.stubs(:qsub).raises(PBS::Error, "The system is down!")
    OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).raises(PBS::Error, "The system is down!")
    OSC::Machete::TorqueHelper.any_instance.stubs(:qdel).raises(PBS::Error, "The system is down!")
  end



  # def test_qstat_fails_following_submit_success
  #   OSC::Machete::TorqueHelper.any_instance.stubs(:qsub).returns("123456.oakley.osc.edu")
  # end

  # def test_update_models_on_index_request
  #   # 1. setup database and torque helper with jobs so that two jobs that are
  #   # cached as queued and running are actually running and passed
  #   OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).returns(OSC::Machete::Status.passed)

  #   # if a test below suddenly returns "Passed" instead of running it might be
  #   # because the signature of qstat or the arguments Job#status is passing to
  #   # these by default are different. 
  #   OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).with("125", any_parameters).returns(OSC::Machete::Status.running)
  #   OSC::Machete::TorqueHelper.any_instance.stubs(:qstat).with("127", any_parameters).returns(OSC::Machete::Status.queued)

  #   # FIXME: move to a controller test?
  #   assert_equal @sims.length, SimulationJob.count, "Test database is not cleaned up after each test is run"

  #   # 2. when doing a get request, the active jobs should be updated
  #   get "/simulations"
  #   assert_response :success

  #   # 3. we verify the modifications to the active jobs took place
  #   assert_equal OSC::Machete::Status.passed, SimulationJob.where(pbsid: "123").first.status
  #   assert_equal OSC::Machete::Status.not_submitted, SimulationJob.where(pbsid: "124").first.status
  #   assert_equal OSC::Machete::Status.running, SimulationJob.where(pbsid: "125").first.status
  #   assert_equal OSC::Machete::Status.passed, SimulationJob.where(pbsid: "126").first.status
  #   assert_equal OSC::Machete::Status.queued, SimulationJob.where(pbsid: "127").first.status
  # end
end

