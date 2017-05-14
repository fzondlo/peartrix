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
    named_results(sql).each_with_object({}) do |row, memo|
      memo[row[:person1]] = row[:person2]
      memo[row[:person2]] = row[:person1]
    end
  end

  def self.number_of_times_paired(person_ids)
    sql = <<~SQL 
      SELECT person1, person2, count(*) as count
      FROM pair_histories
      WHERE (person1 in (#{person_ids.join(',')})
        OR person2 in (#{person_ids.join(',')}))
        AND created_at > '#{90.days.ago}'
      GROUP BY person1, person2;
    SQL
    named_results(sql).each_with_object(Hash.new(0)) do |row, memo|
      key = [ row[:person1], row[:person2] ]
      memo[key] = row[:count]
    end
  end

  private

  def self.named_results(raw_sql_query)
    results = ActiveRecord::Base.connection.select_all(raw_sql_query)
    results.rows.map{ |row| Hash[results.columns.map(&:to_sym).zip(row)] }
  end

  def validate_order
    if person1 > person2
      errors.add(:person, 'Pair history must be ordered by person id before save!')
    end
  end
end
