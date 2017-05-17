class TeamDecorator

  attr_reader :model

  delegate :id, to: :model

  def initialize(model)
    @model = model
  end

  def team_members
    @team_members ||= model.team_members.to_a.map do |member|
      TeamMemberDecorator.new(
        model: member,
        overrides: {},
        last_paired_with_id: last_paired_with_by_id(member.id),
        pair_counts: pairing_counts.for(member)
      )
    end
  end

  def members_left_to_pair
    team_members.reject(&:paired?)
  end

  def next_member_to_pair
    members_by_pair_count = members_left_to_pair.each_with_object(Hash.new{|h,v| h[v] = []}) do |member, memo|
      memo[pairing_counts.lowest_count_for(member)] << member
    end
    min_pair_count = members_by_pair_count.keys.min
    members_by_pair_count[min_pair_count].sample
  end

  def available_member_ids
    members_left_to_pair.map(&:id)
  end

  def set_pair(member1, member2)
    member1.paired_with = member2
    if %w(solo out_of_office).exclude? member2.name
      member2.paired_with = member1
    end
  end

  private

  def last_paired_with_by_id(person_id)
    @last_paired_with_by_id ||=
      PairHistory.last_time_pairing_by_id(model.team_members.pluck(:id) << TeamMember.solo.id)
    @last_paired_with_by_id.dig(person_id, :paired_with)
  end

  def pairing_counts
    @pairing_counts ||= PairingCounts.new(model.team_members)
  end
end
