class PairHistory < ApplicationRecord
  before_validation :validate_order

  # example return:
  # {1: {paired_with: 2, on: 2/3/2015}, 2: {paired_with: 1, on: 2/3/2015}}
  def self.last_time_pairing_by_id(person_ids)
    sql = <<~SQL
      SELECT person1, person2, max(date) as cur_date
      FROM pair_histories
      WHERE (person1 in (#{person_ids.join(',')})
        AND person2 in (#{person_ids.join(',')}))
        AND date > '#{90.days.ago}'
      GROUP BY person1, person2;
    SQL

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

  # example return:
  # {[5, 21]=>1, [21, 22]=>1}
  # this gives you a hash with the keys as the two person's ids in
  # an array and the value is the number of times paired
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

  # example return:
  # {["solo", "b"]=>1, ["b", "a"]=>1}
  # this gives you a hash with the keys as the two person's names
  # in an array and the value is the number of times paired
  def self.number_of_times_paired_by_name(person_ids)
    results_by_id = number_of_times_paired(person_ids)
    out_of_office_id = TeamMember.out_of_office.id
    solo_id = TeamMember.solo.id
    persons = TeamMember.where(id: person_ids + [solo_id, out_of_office_id]).to_a
    names_by_id = Hash[persons.map(&:id).zip(persons.map(&:name))]
    results_by_id.each_pair.with_object({}) do |(key, value), memo|
      name1, name2 = names_by_id[key.first], names_by_id[key.last]
      memo[[name1, name2]] = value
    end
  end


  # example return:
  # {"b"=> {"b"=>0, "a"=>1, "solo"=>0, "out_of_office"=>0},
  #  "a"=> {"b"=>1, "a"=>0, "solo"=>0, "out_of_office"=>0}}
  def self.pair_matrix_per_person(team)
    ids = team.team_members.pluck(:id)
    ungrouped_pairs = number_of_times_paired_by_name(ids)
    team_member_names = team.members_including_statuses.pluck(:name)

    members_hash_with_zero_values = Hash[team_member_names.map {|x| [x, 0] }]
    pairs_by_person = team_member_names.each_with_object({}) do |name, memo|
      memo[name] = members_hash_with_zero_values.dup
    end

    ungrouped_pairs.each_pair do |(name_one, name_two), count|
      pairs_by_person[name_one][name_two] = count
      pairs_by_person[name_two][name_one] = count
    end

    pairs_by_person
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