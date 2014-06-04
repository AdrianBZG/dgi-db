module Genome
  module Groupers
    class DrugGrouper
      @alt_to_pubchem = Hash.new() {|hash, key| hash[key] = []}
      @alt_to_other = Hash.new() {|hash, key| hash[key] = []}

      def self.run
        ActiveRecord::Base.transaction do
          puts 'preload'
          preload
          puts 'create groups'
          create_groups
          puts 'add members'
          add_members
        end
      end

      def self.preload
        DrugClaimAlias.includes(drug_claim: [:drugs, :source]).all.each do |dca|
          drug_claim_alias = dca.alias
          next if drug_claim_alias.length == 1
          next if drug_claim_alias =~ /^\d\d$/

          if dca.nomenclature == 'pubchem_primary_name'
            @alt_to_pubchem[drug_claim_alias] << dca
          else
            @alt_to_other[drug_claim_alias] << dca
          end
        end
      end

      def self.create_groups
        @alt_to_pubchem.each_key do |key|
          drug_claims = @alt_to_pubchem[key].map(&:drug_claim)
          drug = Drug.where(name: key).first
          if drug 
            drug_claims.each do |drug_claim|
              drug_claim.drugs << drug unless drug_claim.drugs.include?(drug)
              drug_claim.save
            end
          else
            Drug.new.tap do |g|
              g.name = key
              g.drug_claims = drug_claims
              g.save
            end
          end
        end
      end

      def self.add_members
        DrugClaim.all.each do |drug_claim|
          next if drug_claim.drugs.any?
          indirect_groups = Hash.new { |h, k| h[k] = 0 }
          direct_groups = Hash.new { |h, k| h[k] = 0 }

          direct_groups[drug_claim.name] += 1 if Drug.where(name: drug_claim.name).any?
          drug_claim.drug_claim_aliases.each do |drug_claim_alias|
            direct_groups[drug_claim_alias.alias] +=1 if Drug.where(name: drug_claim_alias.alias).any?
            alt_drugs = @alt_to_other[drug_claim_alias.alias].map(&:drug_claim)
            alt_drugs.each do |alt_drug|
              indirect_drug = alt_drug.drugs.first
              indirect_groups[indirect_drug.name] += 1 if indirect_drug
            end
          end

          if direct_groups.keys.length == 1
            drug = Drug.where(name: direct_groups.keys.first).first
            drug.drug_claims << drug_claim unless drug.drug_claims.include?(drug_claim)
            drug.save
          elsif direct_groups.keys.length == 0 && indirect_groups.keys.length == 1
            drug = Drug.where(name: indirect_groups.keys.first).first
            drug.drug_claims << drug_claim unless drug.drug_claims.include?(drug_claim)
            drug.save
          end
        end
      end
    end
  end
end
