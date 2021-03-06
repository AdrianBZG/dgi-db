require 'genome/online_updater'

module Genome; module OnlineUpdaters; module Ckb;
  class Updater < Genome::OnlineUpdater
    attr_reader :new_version
    def initialize(source_db_version = Date.today.strftime("%d-%B-%Y"))
      @new_version = source_db_version
    end

    def update
      remove_existing_source
      create_new_source
      create_interaction_claims
    end

    private
    def remove_existing_source
      Utils::Database.delete_source('CKB')
    end

    def create_new_source
      @source ||= DataModel::Source.create(
        {
          source_db_name: 'CKB',
          source_db_version: new_version,
          base_url: 'https://ckb.jax.org/gene/show?geneId=',
          site_url: 'https://ckb.jax.org',
          citation: 'Sara E. Patterson, Rangjiao Liu, Cara M. Statz, Daniel Durkin, Anuradha Lakshminarayana, and Susan M. Mockus. The Clinical Trial Landscape in Oncology and Connectivity of Somatic Mutational Profiles to Targeted Therapies. Human Genomics, 2016 Jan 16;10(1):4. (PMID: 26772741)',
          source_type_id: DataModel::SourceType.INTERACTION,
          full_name: 'The Jackson Laboratory Clinical Knowledgebase',
        }
      )
    end

    def create_interaction_claims
      api_client = ApiClient.new
      api_client.genes.each do |gene|
        gene_claim = create_gene_claim(gene['geneName'], 'CKB Gene Name')
        create_gene_claim_aliases(gene_claim, gene)
        api_client.interactions_for_gene_id(gene['id']).each do |interaction|
          drug_name = interaction['Therapy Name']
          if drug_name.include? '+'
            combination_drug_name = drug_name
            combination_drug_name.split(' + ').each do |individual_drug_name|
              drug_claim = create_drug_claim(individual_drug_name, individual_drug_name, 'CKB Drug Name')
              interaction_claim = create_interaction_claim(gene_claim, drug_claim)
              create_interaction_claim_attribute(interaction_claim, 'combination therapy', combination_drug_name)
              create_interaction_claim_publications(interaction_claim, interaction['References'])
              create_interaction_claim_attributes(interaction_claim, interaction)
            end
          else
            drug_claim = create_drug_claim(drug_name, drug_name, 'CKB Drug Name')
            interaction_claim = create_interaction_claim(gene_claim, drug_claim)
            create_interaction_claim_publications(interaction_claim, interaction['References'])
            create_interaction_claim_attributes(interaction_claim, interaction)
          end
        end
      end
    end

    def create_gene_claim_aliases(gene_claim, gene)
      create_gene_claim_alias(gene_claim, gene['id'], 'CKB Entrez Id')
      gene['text'].split(' | ').each do |synonym|
        create_gene_claim_alias(gene_claim, synonym, 'CKB Gene Synonym')
      end
    end

    def create_interaction_claim_publications(interaction_claim, publications)
      publications.split.select { |p| valid_pmid?(p) }.each do |pmid|
        create_interaction_claim_publication(interaction_claim, pmid)
      end
    end

    def valid_pmid?(pmid)
      pmid.to_i.to_s == pmid
    end

    def create_interaction_claim_attributes(interaction_claim, interaction)
      ['Indication/Tumor Type', 'Response Type', 'Approval Status', 'Evidence Type'].each do |name|
        create_interaction_claim_attribute(interaction_claim, name, interaction[name])
      end
    end
  end
end; end; end;
