class GeneClaimAlias < ActiveRecord::Base
  include Genome::Extensions::UUIDPrimaryKey
  belongs_to :gene_claim

  def self.for_search
    eager_load(gene_claim: [genes: [gene_claims: {interaction_claims: { source: [], drug_claim: [:source], interaction_claim_types: [], gene_claim: [genes: [gene_claims: [:gene_claim_categories]]]}}]])
  end

  def self.for_gene_categories
    eager_load(gene_claim: [genes: [gene_claims: [:source, :gene_claim_categories]]])
  end
end
