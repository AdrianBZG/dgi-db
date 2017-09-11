module Backup
  class DrugClaimAttribute < Base
    include Genome::Extensions::UUIDPrimaryKey
    belongs_to :drug_claim, inverse_of: :drug_claim_attributes
  end
end
