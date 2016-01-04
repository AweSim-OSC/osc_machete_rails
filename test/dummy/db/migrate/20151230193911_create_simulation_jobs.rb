class CreateSimulationJobs < ActiveRecord::Migration
  def change
    create_table :simulation_jobs do |t|
      t.string :name
      t.float :pressure
      t.references :simulation, index: true
      t.string :status
      t.string :pbsid
      t.string :job_path
      t.string :script_name

      t.timestamps
    end
  end
end
