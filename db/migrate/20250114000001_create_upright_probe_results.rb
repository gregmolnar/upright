class CreateUprightProbeResults < ActiveRecord::Migration[8.0]
  def change
    create_table :upright_probe_results do |t|
      t.string :probe_name
      t.string :probe_type
      t.string :probe_target
      t.string :probe_service
      t.decimal :duration
      t.integer :status

      t.timestamps
    end

    add_index :upright_probe_results, :probe_type
    add_index :upright_probe_results, :probe_name
    add_index :upright_probe_results, :status
    add_index :upright_probe_results, :created_at
  end
end
