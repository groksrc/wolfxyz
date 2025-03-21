class CreateJobApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :job_applications do |t|
      t.references :job_seeker, null: false, foreign_key: true, index: true
      t.references :opportunity, null: false, foreign_key: true, index: true
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :job_applications, [:job_seeker_id, :opportunity_id], unique: true, name: 'idx_job_applications_on_job_seeker_and_opportunity'
  end
end
