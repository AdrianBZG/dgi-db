class InteractionClaimTypeFilter
  include Filter
  def initialize(type)
    @type = type.downcase
  end

  def cache_key
    "interaction.type.#{@type}"
  end

  def axis
    :interactions
  end

  def resolve
    Set.new DataModel::InteractionClaimType
      .where('lower(type) = ?', @type)
      .includes(:interaction_claims)
      .select("interaction_claims.id")
      .first.interaction_claims
      .pluck(:id)
  end
end
