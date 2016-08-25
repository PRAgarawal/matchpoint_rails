class IndexOnlyRestfulController < ApplicationController
  include RestfulHelper

  before_action :set_default_request_format, :authenticate_user!
  after_action :verify_policy_scoped, :only => :index

  def set_default_request_format
    request.format = "json" unless params[:format]
  end

  # Scope modifiers available to all controllers extending this class:
  # offset: Amount to offset data (ex offset of 20 will skip the first 20 results). Zero by default.
  # limit: ex a limit of 20 will return the first 20 results after the offset. Infinite by default.
  def index
    @all_records = index_scope(policy_scope(resource_class))
    @records = apply_page_query_parameters(@all_records)

    respond_to do |format|
      format.html { render_records(@records) }
      format.json { render_records(@records) }
      format.csv {
        # This encode call for now just deletes all funky UTF-8 characters that we have not yet
        # accounted for. If this causes the loss of any relevant data, we may have to just change
        # this to an excel output rather than csv
        send_data index_csv(@all_records).encode('iso-8859-1',
                                                 {invalid: :replace, undef: :replace, replace: ''}),
                  type: 'text/csv; charset=iso-8859-1; header=present',
                  filename: "#{self.controller_name}_#{Date.today.to_s}.csv"
      }
    end
  end

  protected

  def index_csv(records)
    csv_data = csv_data()
    CSV.generate do |csv|
      if csv_data[:titles].present?
        csv << csv_data[:titles]
      else
        csv << titleize(csv_data[:names])
      end

      records.as_json(csv_data[:includes]).each do |row|
        csv << flatten_hash(row).values_at(*csv_data[:names])
      end
    end
  end

  # Override this function to create custom CSV downloads
  # params:
  # names - the names of the attributes to retrieve
  # titles - the titles of each column to show to the end user
  # includes - (not used by default) contains the objects/methods to include in rendering
  #            the CSV.
  def csv_data
    cols = {names: [], titles: []}
    resource_class.columns.map do |col|
      cols[:names].push col.name
    end
    cols[:titles] = titleize(cols[:names])
    cols
  end

  def titleize(names)
    cols = []
    names.each do |name|
      cols.push name.titleize
    end
    cols
  end

  def apply_page_query_parameters(scope)
    limit = params[:limit].to_i
    offset_value = params[:offset].to_i
    paged_scope = scope

    if offset_value > 0
      paged_scope = paged_scope.offset(offset_value)
    end

    if limit > 0
      paged_scope = paged_scope.limit(limit)
    end

    if params[:show_count] == 'true'
      response.headers['X-RU-Record-Count'] = scope.size.to_s
    end

    return paged_scope
  end

  def render_records(records)
    # Use the MultiJson.dump call here since it speeds up rendering of large amounts of JSON
    render json: MultiJson.dump(records)
  end

  def index_scope(scope)
    scope
  end

  # The resource class based on the controller
  # @return [Class]
  def resource_class
    @resource_class ||= self.controller_name.singularize.classify.constantize
  end
end
