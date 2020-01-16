class CreateSimulations < ActiveRecord::Migration[4.2]
  def change
    create_table :simulations do |t|
      t.string :name
      t.float :pressure
      t.string :staged_dir

      t.timestamps
    end
  end
end
