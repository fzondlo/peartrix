class CreatePairHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :pair_histories do |t|
      t.integer :person1
      t.integer :person2

      t.timestamps
    end
  end
end
