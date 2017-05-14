class CreatePairHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :pair_histories do |t|
      t.integer :person1, null: false
      t.integer :person2, null: false
      t.integer :team_id, null: false
      t.date :date, null: false
    end
  end
end
