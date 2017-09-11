module Utils
  module Database

    def self.delete_genes
      sql = <<-SQL
        update gene_claims set gene_id = NULL;
        
        delete from gene_aliases_sources;
        delete from gene_aliases;
        delete from gene_attributes_sources;
        delete from gene_attributes;
        delete from gene_categories_genes;
        delete from genes;
      SQL

      ActiveRecord::Base.transaction do
        delete_interactions
        ActiveRecord::Base.connection.execute(sql)
      end
    end

    def self.delete_interactions
      sql = <<-SQL
        update interaction_claims set interaction_id = NULL;
        
        delete from interaction_attributes_sources;
        delete from interaction_attributes;
        delete from interactions_publications;
        delete from interaction_types_interactions;
        delete from interactions_publications;
        delete from interactions_sources;
        delete from interactions;
      SQL

      ActiveRecord::Base.connection.execute(sql)
    end

    def self.delete_drugs
      sql = <<-SQL
        update drug_claims set drug_id = NULL;
        
        delete from drug_aliases_sources;
        delete from drug_aliases;
        delete from drug_attributes_sources;
        delete from drug_attributes;
        delete from drugs;
      SQL

      ActiveRecord::Base.transaction do
        delete_interactions
        ActiveRecord::Base.connection.execute(sql)
      end
    end

    def self.delete_source(source_db_name)
      source_id = DataModel::Source.where('lower(sources.source_db_name) = ?',
        source_db_name.downcase).pluck(:id).first

      if source_id
        sql = <<-SQL
          delete from interaction_claims_publications where interaction_claim_id in (select id from interaction_claims where source_id = '#{source_id}');
          delete from interaction_claim_attributes where interaction_claim_id in (select id from interaction_claims where source_id = '#{source_id}');
          delete from interaction_claim_types_interaction_claims where interaction_claim_id in (select id from interaction_claims where source_id = '#{source_id}');
          update interaction_claims set interaction_id = NULL where source_id = '#{source_id}';
          delete from interaction_claims where source_id = '#{source_id}';

          delete from interactions_sources where source_id = '#{source_id}';

          delete from drug_claim_attributes where drug_claim_id in (select id from drug_claims where source_id = '#{source_id}');
          delete from drug_claim_aliases where drug_claim_id in (select id from drug_claims where source_id = '#{source_id}');
          delete from drug_claim_types_drug_claims where drug_claim_id in (select id from drug_claims where source_id = '#{source_id}');
          update drug_claims set drug_id = NULL where source_id = '#{source_id}';
          delete from drug_claims where source_id = '#{source_id}';

          delete from gene_gene_interaction_claim_attributes where gene_gene_interaction_claim_id in (select id from gene_gene_interaction_claims where source_id = '#{source_id}');
          delete from gene_gene_interaction_claims where source_id = '#{source_id}';

          delete from gene_claim_attributes where gene_claim_id in (select id from gene_claims where source_id = '#{source_id}');
          delete from gene_claim_aliases where gene_claim_id in (select id from gene_claims where source_id = '#{source_id}');
          delete from gene_claim_categories_gene_claims where gene_claim_id in (select id from gene_claims where source_id = '#{source_id}');
          update gene_claims set gene_id = NULL where source_id = '#{source_id}';
          delete from gene_claims where source_id = '#{source_id}';

          delete from drug_aliases_sources where source_id = '#{source_id}';
          delete from drug_attributes_sources where source_id = '#{source_id}';
          delete from gene_aliases_sources where source_id = '#{source_id}';
          delete from gene_attributes_sources where source_id = '#{source_id}';
          delete from interaction_attributes_sources where source_id = '#{source_id}';
          delete from interactions_sources where source_id = '#{source_id}';
          delete from sources where id = '#{source_id}';
        SQL

        ActiveRecord::Base.connection.execute(sql)
      end
    end

    def self.destroy_common_aliases
      sql = <<-SQL
        DELETE FROM drug_claim_aliases
        WHERE alias in (
          select alias from (
            select * from (
              select count(distinct d.id), alias, length(alias)
              from drugs d, drug_claims_drugs dcd, drug_claim_aliases dca
              where d.id = dcd.drug_id and dcd.drug_claim_id = dca.drug_claim_id
              group by alias
            ) t
            where (count >= 5 and length <= 4) or length <= 2 or count >= 10
          ) t
        )
      SQL
      ActiveRecord::Base.transaction do
        ActiveRecord::Base.connection.execute(sql)
        destroy_empty_groups
      end
    end

    def self.destroy_empty_groups
      DataModel::Interaction.includes(:interaction_claims).where(interaction_claims: {id: nil}).destroy_all
      # Empty genes are expected
      # empty_genes = DataModel::Gene.includes(:gene_claims).where(gene_claims: {id: nil}).destroy_all
      # Empty drugs are okay to delete
      DataModel::Drug.includes(:drug_claims).where(drug_claims: {id: nil}).destroy_all
    end

    def self.destroy_na
      sql = <<-SQL
        delete from drug_claim_types_drug_claims d
        where
        d.drug_claim_id in
          (select id from drug_claims
          where upper(drug_claims.name) in ('NA','N/A')
          );

        delete from drug_claims_drugs d
        where
        d.drug_claim_id in
          (select id from drug_claims
          where upper(drug_claims.name) in ('NA','N/A')
          );

        delete from drug_claim_aliases d
        where
        d.drug_claim_id in
          (select id from drug_claims
          where upper(drug_claims.name) in ('NA','N/A')
          );

        delete from drug_claim_attributes d
        where
        d.drug_claim_id in
          (select id from drug_claims
          where upper(drug_claims.name) in ('NA','N/A')
          );

        delete from interaction_claim_types_interaction_claims i
        where
        i.interaction_claim_id in
          (select id from interaction_claims d
          where
          d.drug_claim_id in
            (select id from drug_claims
            where upper(drug_claims.name) in ('NA','N/A')
            )
          );

        delete from interaction_claim_attributes i
        where
        i.interaction_claim_id in
          (select id from interaction_claims d
          where
          d.drug_claim_id in
            (select id from drug_claims
            where upper(drug_claims.name) in ('NA','N/A')
            )
          );

        delete from interaction_claims d
        where
        d.drug_claim_id in
          (select id from drug_claims
          where upper(drug_claims.name) in ('NA','N/A')
          );

        delete from drug_claims d
        where
        upper(name) in ('NA','N/A');

        delete from drug_claim_aliases
        where upper(alias) in ('NA','N/A');

        delete from gene_claim_aliases g
        where
        g.gene_claim_id in
          (select id from gene_claims
          where upper(name) in ('NA','N/A')
          );

        delete from gene_claim_attributes g
        where
        g.gene_claim_id in
          (select id from gene_claims
          where upper(name) in ('NA','N/A')
          );

        delete from interaction_claim_types_interaction_claims i
        where
        i.interaction_claim_id in
          (select id from interaction_claims
          where
            interaction_claims.gene_claim_id in
            (select id from gene_claims
            where upper(name) in ('NA','N/A')
            )
          );

        delete from interaction_claim_attributes i
        where
        i.interaction_claim_id in
          (select id from interaction_claims
          where
            interaction_claims.gene_claim_id in
            (select id from gene_claims
            where upper(name) in ('NA','N/A')
            )
          );

        delete from interaction_claims g
        where
        g.gene_claim_id in
          (select id from gene_claims
          where upper(name) in ('NA','N/A')
          );

        delete from gene_claims
        where upper(name) in ('NA','N/A');

        delete from gene_claim_aliases
        where upper(alias) in ('NA', 'N/A');
      SQL

      ActiveRecord::Base.connection.execute(sql)
    end

    def self.model_to_tsv(model)
      CSV.generate(col_sep: "\t") do |tsv|
        tsv << model.column_names
        model.all.each do |m|
          values = model.column_names.map{ |f| m.send f.to_sym}
          tsv << values
        end
      end
    end

    class Restore
      attr_accessor :current_source, :backup_source, :source_type, :claim_map

      def initialize(source_db_name, backup_source_db_name=nil)
        if backup_source_db_name.nil?
          backup_source_db_name = source_db_name
        end
        @current_source = DataModel::Source.find_by(source_db_name: source_db_name)
        @backup_source = Backup::Source.find_by(source_db_name: backup_source_db_name)
        @source_type = backup_source.source_type
        @claim_map = {}
      end

      def restore_all_claims
        # By default, the source name is the same between current and backup
        if backup_source.source_db_version != current_source.source_db_version
          return unless HighLine.agree("Current version #{current_version} is not the same as backup version #{old_version}. Continue?")
        end

        restore_source
        if source_type.type == 'interaction'
          restore_gene_claims
          restore_drug_claims
          restore_interaction_claims
        end
        pg = PostGrouper.new
        pg.perform
        current_source.reload
      end

      def restore_source
        unless current_source.nil?
          Utils::Database.delete_source current_source.source_db_name
        end
        columns = %w( source_db_name source_db_version citation base_url site_url full_name )
        new_source = DataModel::Source.new(backup_source.attributes.select {|k, _| columns.include? k})
        new_source.source_trust_level = DataModel::SourceTrustLevel.find_by(level: backup_source.source_trust_level.level)
        new_source.source_type = DataModel::SourceType.find_by(type: source_type.type)
        new_source.save!
        @current_source = new_source
      end

      def restore_gene_claims
        #TODO: Have column names auto-generate instead of being defined
        gc_columns = %w(name nomenclature)
        gc_alias_columns = %w(alias nomenclature)
        gc_attribute_columns = %w(name value)
        gc_category_columns = %w(name)
        Backup::GeneClaim.eager_load([:gene_claim_aliases, :gene_claim_attributes]).where(source: backup_source).each do |backup_gc|
          new_gc = DataModel::GeneClaim.new(backup_gc.attributes.select { |k, _| gc_columns.include? k})
          new_gc.source = current_source
          new_gc.save!
          claim_map[backup_gc.id] = new_gc.id
          gc_alias_attribs = construct_gene_claim_attributes(gc_alias_columns, new_gc, 'gene_claim_aliases')
          DataModel::GeneClaimAlias.create(gc_alias_attribs)
          gc_attribute_attribs = construct_gene_claim_attributes(gc_attribute_columns, new_gc, 'gene_claim_attributes')
          DataModel::GeneClaimAttribute.create(gc_attribute_attribs)
          new_gc.gene_claim_categories = backup_gc.gene_claim_categories.map do |gcg|
            attributes = gcg.attributes.select { |k, _| gc_category_columns.include? k}
            DataModel::GeneClaimCategory.where(attributes).first_or_create!
          end.uniq
        end
      end

      def restore_drug_claims
        #TODO: Have column names auto-generate instead of being defined
        dc_columns = %w(name nomenclature primary_name)
        dc_alias_columns = %w(alias nomenclature)
        dc_attribute_columns = %w(name value)
        dc_type_columns = %w(type)
        Backup::DrugClaim.eager_load([:drug_claim_attributes, :drug_claim_aliases]).where(source: backup_source).each do |backup_dc|
          new_dc = DataModel::DrugClaim.new(backup_dc.attributes.select { |k, _| dc_columns.include? k})
          new_dc.source = current_source
          new_dc.save!
          claim_map[backup_dc.id] = new_dc.id
          dc_alias_attribs = construct_drug_claim_attributes(dc_alias_columns, new_dc, 'drug_claim_aliases')
          DataModel::DrugClaimAlias.create(dc_alias_attribs)
          dc_attribute_attribs = construct_drug_claim_attributes(dc_attribute_columns, new_dc, 'drug_claim_attributes')
          DataModel::DrugClaimAttribute.create(dc_attribute_attribs)
          new_dc.drug_claim_types = backup_dc.drug_claim_types.map do |dct|
            attributes = dct.attributes.select { |k, _| dc_type_columns.include? k}
            DataModel::DrugClaimType.where(attributes).first_or_create!
          end.uniq
        end
      end

      def restore_interaction_claims
        #TODO: Have column names auto-generate instead of being defined
        ic_attributes_columns = %w(name value)
        ic_type_columns = %w(type)
        Backup::InteractionClaim.eager_load(:interaction_claim_types, :interaction_claim_attributes, :gene_claim, :drug_claim).where(source: backup_source).each do |backup_ic|
          gene_claim_id = lookup_claim_id(backup_ic.gene_claim, %w(name nomenclature))
          drug_claim_id = lookup_claim_id(backup_ic.drug_claim, %w(name nomenclature primary_name))
          new_ic = DataModel::InteractionClaim.where(gene_claim_id: gene_claim_id,
                                                   drug_claim_id: drug_claim_id,
                                                   source_id: current_source.id).first_or_create!
          ic_attribute_attribs = construct_interaction_claim_attributes(ic_attributes_columns, new_ic, 'interaction_claim_attributes')
          DataModel::InteractionClaimAttribute.where(ic_attribute_attribs).first_or_create!
          new_ic.interaction_claim_types = backup_ic.interaction_claim_types.map do |ict|
            attributes = ict.attributes.select { |k, _| ic_type_columns.include? k}
            DataModel::InteractionClaimType.where(attributes).first_or_create!
          end.uniq
        end
      end

      private
      def construct_attributes(fields, parent_claim, associated_object_name, linking_id_name)
        parent_claim.send(associated_object_name).map do |record|
          attributes = record.attributes.select { |k, _| fields.include? k}
          if parent_claim.nil?
            attributes[linking_id_name] = nil
          else
            attributes[linking_id_name] = parent_claim.id
          end
          attributes
        end.uniq
      end

      def construct_gene_claim_attributes(fields, gene_claim, associated_object_name)
        construct_attributes(fields, gene_claim, associated_object_name, 'gene_claim_id')
      end

      def construct_drug_claim_attributes(fields, drug_claim, associated_object_name)
        construct_attributes(fields, drug_claim, associated_object_name, 'drug_claim_id')
      end

      def construct_interaction_claim_attributes(fields, interaction_claim, associated_object_name)
        construct_attributes(fields, interaction_claim, associated_object_name, 'interaction_claim_id')
      end

      def lookup_claim_id(object, fields)
        new_id = claim_map[object.id]
        return new_id if new_id
        klass = ('DataModel::' + object.class.name.demodulize).constantize
        attribs = object.attributes.select { |k, _| fields.include? k}
        new_obj = klass.find_by!(attribs)
        claim_map[object.id] = new_obj.id
      end

    end

  end
end
