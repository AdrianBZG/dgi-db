class InteractionClaimsController < ApplicationController
  caches_page :show
  def show
    @interaction = InteractionClaimPresenter.new(
      DataModel::InteractionClaim.for_show.find(params[:id]))
  end

  def interaction_search_results
    @search_interactions_active = 'active'
    start_time = Time.now
    combine_input_genes(params)
    validate_search_request(params)

    search_results = LookupInteractions.find(params)

    @search_results = InteractionSearchResultsPresenter.new(search_results, start_time)
    if params[:outputFormat] == 'tsv'
      generate_tsv_headers('interactions_export.tsv')
      render 'interactions_export.tsv', content_type: 'text/tsv', layout: false
    end
  end

  private
  def validate_search_request(params)
    bad_request('You must enter at least one gene name to search!') if params[:gene_names].size == 0
    bad_request('You must select at least one source to search!') unless params[:interaction_sources]
    bad_request('You must select at least one category to search!') unless params[:gene_categories]
    bad_request('You must select at least one interaction type to search!') unless params[:interaction_types]
  end

end
