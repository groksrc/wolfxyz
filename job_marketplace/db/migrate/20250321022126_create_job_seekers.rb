class CreateJobSeekers < ActiveRecord::Migration[8.0]
  def change
    create_table :job_seekers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.text :skills

      t.timestamps
    end

    add_index :job_seekers, :email, unique: true
  end
end
