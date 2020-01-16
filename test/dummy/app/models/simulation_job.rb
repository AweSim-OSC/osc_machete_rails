class SimulationJob < ApplicationRecord
  # Here we test the deprecated include method instead of the new
  # OscMacheteRails::Statusable
  # We will want both to work...
  include OSC::Machete::SimpleJob::Statusable

  belongs_to :simulation

  before_destroy { |j| j.job.delete(rmdir: true) if j.job }

  # Determine if the results are valid
  # def results_valid?
  #   # CODE GOES HERE
  # end
end
