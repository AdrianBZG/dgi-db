# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 0) do


  create_table "citation", :id => false, :force => true do |t|
    t.string "id",                :limit => nil, :null => false
    t.string "source_db_name",    :limit => nil, :null => false
    t.string "source_db_version", :limit => nil, :null => false
    t.text   "citation"
    t.string "base_url",          :limit => nil
    t.string "site_url",          :limit => nil
  end

  create_table "drug_gene_interaction_report", :id => false, :force => true do |t|
    t.string "id",                  :limit => nil, :null => false
    t.string "drug_name_report_id", :limit => nil, :null => false
    t.string "gene_name_report_id", :limit => nil, :null => false
    t.string "interaction_type",    :limit => nil
    t.text   "description"
    t.string "citation_id",         :limit => nil
  end

  add_index "drug_gene_interaction_report", ["drug_name_report_id", "gene_name_report_id", "interaction_type"], :name => "drug_gene_interaction_report_drug_name_report_id_key", :unique => true

  create_table "drug_gene_interaction_report_attribute", :id => false, :force => true do |t|
    t.string "id",             :limit => nil, :null => false
    t.string "interaction_id", :limit => nil, :null => false
    t.string "name",           :limit => nil, :null => false
    t.string "value",          :limit => nil, :null => false
  end

  create_table "drug_name_report", :id => false, :force => true do |t|
    t.string "id",           :limit => nil, :null => false
    t.string "name",         :limit => nil, :null => false
    t.text   "description"
    t.string "nomenclature", :limit => nil, :null => false
    t.string "citation_id",  :limit => nil
  end

  add_index "drug_name_report", ["name"], :name => "drug_name_report_name_index"

  create_table "drug_name_report_association", :id => false, :force => true do |t|
    t.string "id",                  :limit => nil, :null => false
    t.string "drug_name_report_id", :limit => nil, :null => false
    t.string "alternate_name",      :limit => nil, :null => false
    t.text   "description"
    t.string "nomenclature",        :limit => nil, :null => false
  end

  add_index "drug_name_report_association", ["drug_name_report_id"], :name => "drug_name_report_id_index"

  create_table "drug_name_report_category_association", :id => false, :force => true do |t|
    t.string "id",                  :limit => nil, :null => false
    t.string "drug_name_report_id", :limit => nil, :null => false
    t.string "category_name",       :limit => nil, :null => false
    t.string "category_value",      :limit => nil, :null => false
    t.text   "description"
  end

  create_table "gene_name_group", :id => false, :force => true do |t|
    t.string "id",   :limit => nil, :null => false
    t.text   "name"
  end

  create_table "gene_name_group_bridge", :id => false, :force => true do |t|
    t.string "gene_name_group_id",  :limit => nil, :null => false
    t.string "gene_name_report_id", :limit => nil, :null => false
  end

  create_table "gene_name_report", :id => false, :force => true do |t|
    t.string "id",           :limit => nil, :null => false
    t.string "name",         :limit => nil, :null => false
    t.text   "description"
    t.string "nomenclature", :limit => nil, :null => false
    t.string "citation_id",  :limit => nil
  end

  add_index "gene_name_report", ["name"], :name => "gene_name_report_name_index"

  create_table "gene_name_report_association", :id => false, :force => true do |t|
    t.string "id",                  :limit => nil, :null => false
    t.string "gene_name_report_id", :limit => nil, :null => false
    t.string "alternate_name",      :limit => nil, :null => false
    t.text   "description"
    t.string "nomenclature",        :limit => nil, :null => false
  end

  add_index "gene_name_report_association", ["alternate_name"], :name => "alternate_name_index"

  create_table "gene_name_report_category_association", :id => false, :force => true do |t|
    t.string "id",                  :limit => nil, :null => false
    t.string "gene_name_report_id", :limit => nil, :null => false
    t.string "category_name",       :limit => nil, :null => false
    t.string "category_value",      :limit => nil, :null => false
    t.text   "description"
  end

end