require 'minitest/autorun'
require 'mocha/minitest'
require 'osc/machete'

class StatusableTest < Minitest::Test
  # FIXME: the problem here: we are extending, not including, so
  # Statusable#included never called
  # 
  # Change the tests to do this appropriately!
  # Or just use a dummy object SimulationJob
  def setup
    @job = SimulationJob.create(pbsid: "123456.oak-batch.osc.edu", job_path: "/path/to/tmp", script_name: "test.sh")
    @job_without_script_name = SimulationJob.create(pbsid: "123456.oak-batch.osc.edu", job_path: "/path/to/tmp")
  end

  def teardown
    @job.delete
    @job_without_script_name.delete
  end

  # verify both of these calls work without crashing
  def test_job_getter_works
    assert_equal "test.sh", @job.job.script_name
    assert_nil @job_without_script_name.job.script_name
  end

  # if calling status returns :Q for Queued, make sure this
  def test_status_sym
    @job.status = nil
    assert ! @job.submitted?
    assert @job.not_submitted?

    @job.status = :Q

    assert @job.submitted?
    assert ! @job.completed?
    assert @job.active?
    assert_equal "Queued", @job.status.to_s

    @job.status = :R
    assert @job.active?
    assert_equal "Running", @job.status.to_s

    @job.status = :C
    assert @job.completed?, "completed? should return true when status is C"
    assert ! @job.failed?, "failed? should return false when status is not F"

    @job.status = :F
    assert @job.completed?, "completed? should return true when status is F"
    assert ! @job.passed?, "passed? should return false when status is F"
    assert @job.failed?, "failed? should return true when status is F"
  end

  def test_status_str
    @job.status = "Q"

    assert @job.submitted?
    assert ! @job.completed?
    assert @job.active?
    assert_equal "Queued", @job.status.to_s

    @job.status = "R"
    assert @job.active?
    assert_equal "Running", @job.status.to_s

    @job.status = "C"
    assert @job.completed?, "completed? should return true when status is C"
    assert ! @job.failed?, "failed? should return false when status is not F"

    @job.status = "F"
    assert @job.completed?, "completed? should return true when status is F"
    assert ! @job.passed?, "passed? should return false when status is F"
    assert @job.failed?, "failed? should return true when status is F"
  end


  def test_results_valid_hook_called
    OSC::Machete::Job.any_instance.stubs(:status).returns(OSC::Machete::Status.passed)
    @job.status = "R"
    @job.expects(:"results_valid?").at_least_once
    @job.update_status!


    # sometimes, qstat returns "C": still call the hook!
    assert_equal OSC::Machete::Status.passed, @job.job.status

    @job.status = "R"
    @job.expects(:"results_valid?").at_least_once
    @job.update_status!

    # but if the status is completed we don't want the hook to run again
    @job.expects(:"results_valid?").never
    @job.status = "C"
    @job.update_status!
  end

  # if status is R but also saved record is also R we shouldn't save
  def test_save_after_update_when_status_returns_symbol
    OSC::Machete::Job.any_instance.stubs(:status).returns(OSC::Machete::Status.running)
    assert OSC::Machete::Status.running, @job.job.status

    @job.expects(:"save").never
    @job.status = "R"
    @job.update_status!

    @job.expects(:"save").at_least_once
    @job.status = "Q"
    @job.update_status!
  end

  def test_update_status_with_not_submitted_with_pbsid
    OSC::Machete::Job.any_instance.stubs(:status).returns(OSC::Machete::Status.running)
    @job.expects(:"save").at_least_once
    @job.status = nil
    @job.update_status!
  end

  def test_update_status_with_not_submitted_without_pbsid
    OSC::Machete::Job.any_instance.stubs(:status).returns(OSC::Machete::Status.running)
    @job.expects(:"save").never
    @job.pbsid = nil
    @job.status = nil
    @job.update_status!
  end

  def test_default_tesults_valid?
    assert true, @job.results_valid?
  end
end
