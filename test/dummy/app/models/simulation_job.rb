class SimulationJob < ActiveRecord::Base
  include OSC::Machete::SimpleJob::Statusable

  belongs_to :simulation

  before_destroy { |j| j.job.delete(rmdir: true) if j.job }

  # Determine if the results are valid
  # def results_valid?
  #   # CODE GOES HERE
  # end
end
