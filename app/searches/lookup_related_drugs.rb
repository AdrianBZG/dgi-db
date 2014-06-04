class LookupRelatedDrugs

  def self.find(drug_name)
    drugs = Drug.advanced_search(name: drug_name)
    drugs += DrugClaim.preload(:drugs)
      .advanced_search(name: drug_name).flat_map { |dc| dc.drugs }
    drugs += DrugClaimAlias.preload(drug_claim: [:drugs])
      .advanced_search(alias: drug_name)
      .map { |dca| dca.drug_claim }
      .flat_map { |dc| dc.drugs }

    drugs.uniq { |d| d.id }
      .reject { |d| d.name == drug_name }
      .map { |d| RelatedDrugPresenter.new(d) }
  end
end
