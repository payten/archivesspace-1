class ResourcesController <  ApplicationController
  include HandleFaceting
  include ProcessResults
  skip_before_filter  :verify_authenticity_token
  def index
    @repo_name = params[:repo] || ""
    @repo_id = "/repositories/#{params[:rid]}"
    @criteria = {}
    @criteria['sort'] = 'title asc'
    @criteria['resolve[]']  = ['repository:id']
    query = "repository:\"#{@repo_id}\" AND publish:true AND types:resource"
    page_size =  params['page_size'].to_i if !params.blank?
    page_size = AppConfig[:search_results_page_size] if page_size == 0
    page = params['page'] || 1 if !params.blank?
    @criteria[:page_size] = page_size
    # might as well get the facets here
    @results =  archivesspace.search(query, page, @criteria) || {}
    @results = handle_results(@results)
    @pager =  Pager.new("/repositories/#{params[:rid]}/resources?repo=#{@repo_name}", @results['this_page'],@results['last_page'])
    @page_title = (@repo_name != '' ? "#{@repo_name}: " : '') +(@results['results'].length > 1 ? I18n.t('resource._plural') : I18n.t('resource._singular')) +  " " + I18n.t('listing')
    Rails.logger.debug("Page title #{@page_title}")
  end

  def show
    @resource_id = "/repositories/#{params[:rid]}/resources/#{params[:id]}"
    @criteria = {}
    @criteria['resolve[]']  = ['repository:id']
    query = "id:#{@resource_id}"
    @results =  archivesspace.search(query,1, @criteria) || {}
    @results = handle_results(@results)
    if !@results['results'].blank? && @results['results'].length > 0
      @result = @results['results'][0]
      @page_title = "#{I18n.t('resource._singular')}: #{@result['json']['title']}"
    else
      @page_title = "#{I18n.t('resource._singular')} NOT FOUND"
    end
  end
end