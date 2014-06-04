Fabricator(:interaction_claim) do
  source
  drug_claim { |attrs| Fabricate(:drug_claim, source: attrs[:source]) }
  gene_claim { |attrs| Fabricate(:gene_claim, source: attrs[:source]) }
  interaction_type ''
  description ''
  known_action_type { ['known', 'unknown', 'n/a'].sample }
end

Fabricator(:interaction_claim_attribute) do |f|
  f.interaction_claim
  f.name { sequence(:interaction_claim_attr_name) { |i| "Interaction claim attribute name #{i}" } }
  f.value { sequence(:interaction_claim_attr_value) { |i| "Interaction claim attribute value #{i}" } }
end

Fabricator(:interaction_claim_type) do
  type { ['inhibitor', 'n/a', 'antagonist', 'multitarget'].sample }
end
