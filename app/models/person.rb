class Person < ApplicationRecord
  belongs_to :team

  def self.solo
    find_or_create_and_skip_validation(name: 'solo', team_id: 0)
  end

  def self.out_of_office
    find_or_create_and_skip_validation(name: 'out_of_office', team_id: 0)
  end

  private

  def self.find_or_create_and_skip_validation(where_hash)
    where(where_hash).first_or_initialize
      .tap{ |x| x.save!(validate: false) unless x.persisted? }
  end
end
