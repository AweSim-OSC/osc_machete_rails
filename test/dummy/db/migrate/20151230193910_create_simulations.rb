class CreateSimulations < ActiveRecord::Migration
  def change
    create_table :simulations do |t|
      t.string :name
      t.float :pressure
      t.string :staged_dir

      t.timestamps
    end
  end
end
