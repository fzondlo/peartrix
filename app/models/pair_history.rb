class PairHistory < ApplicationRecord
  before_validation :validate_order

  def self.last_time_pairing_by_id(person_ids)
    sql = <<~SQL
      SELECT person1, person2, max(date) as cur_date
      FROM pair_histories
      WHERE (person1 in (#{person_ids.join(',')})
        AND person2 in (#{person_ids.join(',')}))
        AND date > '#{90.days.ago}'
      GROUP BY person1, person2;
    SQL

    # {1: {paired_with: 2, on: 2/3/2015}}
    named_results(sql).each_with_object({}) do |row, memo|
      date = Date.parse row[:cur_date]
      if memo[row[:person1]].nil? || memo[row[:person1]][:on] < date
        memo[row[:person1]] = {paired_with: row[:person2], on: date}
      end

      if memo[row[:person2]].nil? || memo[row[:person2]][:on] < date
        memo[row[:person2]] = {paired_with: row[:person1], on: date}
      end
    end
  end

  def self.number_of_times_paired(person_ids)
    sql = <<~SQL
      SELECT person1, person2, count(*) as count
      FROM pair_histories
      WHERE (person1 in (#{person_ids.join(',')})
        OR person2 in (#{person_ids.join(',')}))
        AND date > '#{90.days.ago}'
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
