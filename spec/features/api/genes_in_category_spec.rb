require 'spec_helper'

describe 'genes_in_category' do
  def setup_category_with_gene
    category = Fabricate(:gene_claim_category, name: 'TESTCATEGORY')
    gene_claim = Fabricate(:gene_claim, gene_claim_categories: [category])
    gene = Fabricate(:gene, gene_claims: [gene_claim])
    [gene, category.name]
  end

  it 'should return a 200 status code when the category exists' do
    (_, category_name) = setup_category_with_gene
    visit "/api/v1/genes_in_category.json?category=#{category_name}"
    page.status_code.should eq(200)
  end

  it 'should return a json array of genes in the category' do
    (gene, category_name) = setup_category_with_gene
    visit "/api/v1/genes_in_category.json?category=#{category_name}"
    body = JSON.parse(page.body)
    body.should be_an_instance_of(Array)
    body.length.should eq 1
    body.first.should eq gene.name
    page.status_code.should eq(200)
  end

  it 'should return a 404 status code when the category does not exist' do
    visit "/api/v1/genes_in_category.json?category=blah"
    page.status_code.should eq(404)
  end
end