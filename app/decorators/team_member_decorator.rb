class TeamMemberDecorator

  attr_accessor :paired_with 
  attr_reader :overrides, :pair_counts, :last_paired_with_id, :model
  delegate :id, :name, 
    :to => :@model

  def initialize(model:, pair_counts:, last_paired_with_id:, overrides: {})
    @model = model
    @pair_counts = pair_counts
    @overrides = overrides
    @last_paired_with_id = last_paired_with_id
  end

  def paired?
    paired_with.present?
  end

  def last_solo?
    last_paired_with_id == TeamMember.solo.id
  end

  def find_best_pair_from(available_member_ids)
    return available_member_ids.first if available_member_ids.one?
    (available_member_ids - [last_paired_with_id]).min do |id|
      pair_counts[id]
    end
  end
end