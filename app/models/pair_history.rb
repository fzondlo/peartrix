class PairHistory < ApplicationRecord
  before_validation :validate_order

  def self.last_time_pairing_by_id(person_ids)
    sql = <<~SQL 
      SELECT person1, person2, max(created_at) as timestamp
      FROM pair_histories
      WHERE (person1 in (#{person_ids.join(',')})
        AND person2 in (#{person_ids.join(',')}))
        AND created_at > '#{90.days.ago}'
      GROUP BY person1, person2;
    SQL
    results = ActiveRecord::Base.connection.execute(sql)
    results.each_with_object({}) do |result, memo|
      memo[result[0]] = result[1]
      memo[result[1]] = result[0]
    end
  end


  def self.number_of_times_paired(person_ids)
    person_ids.sort.combination(2).to_a
    sql = <<~SQL 
      SELECT person1, person2, count(*) as count
      FROM pair_histories
      WHERE (person1 in (#{person_ids.join(',')})
        OR person2 in (#{person_ids.join(',')}))
        AND created_at > '#{90.days.ago}'
      GROUP BY person1, person2;
    SQL
    results = ActiveRecord::Base.connection.execute(sql)
    results.each_with_object({}) do |result, memo|
      memo[[result[0],result[1]]] = result[3]
    end
  end

  private

  def validate_order
    if person1 > person2
      errors.add(:person, 'Pair history must be ordered by person id before save!')
    end
  end
end
