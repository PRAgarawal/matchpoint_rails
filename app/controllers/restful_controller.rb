class RestfulController < IndexOnlyRestfulController
  after_action :verify_authorized, :except => :index

  def create
    rename_params_for_nested_attributes(resource_class, params)
    @record = resource_class.new(allowed_params)
    yield @record if block_given?

    # We need to authorize the record before it's saved, but some authorizations assume
    # values exist.  We ensure it's valid before authorizing it.  If it's not valid, the
    # save! call should throw an exception anyway.
    if @record.valid?
      authorize @record
    end
    @record.save!

    if !block_given?
      render_record @record
    end

    @record
  end

  def update
    ActiveRecord::Base.transaction do
      rename_params_for_nested_attributes(resource_class, params)
      @record = find_record(params)

      # We don't wrap this in a valid? check because we assume data in the database is valid
      authorize @record
      @record.assign_attributes(allowed_params)
      yield @record if block_given?

      # Same as with create, wrap authorize in a valid? check
      if @record.valid?
        authorize @record # Authorize before updating the record and afterwards as well
      end

      result = @record.save!

      if !block_given?
        if result
          render_record @record
        else
          render :plain => false
        end
      end
    end
  end

  def show
    @record = find_record(params)
    authorize @record
    render_record @record
  end

  def destroy
    @record = find_record(params)
    authorize @record
    yield @record if block_given?
    render :json => @record.destroy!
  end

  protected

  # Default to do the same thing as render_records
  def render_record(record)
    render_records(record)
  end

  def find_record(params)
    resource_class.find(params[:id])
  end

  def allowed_params
    action = params.as_json["action"]
    policy_with = @record ? @record : resource_class
    params.permit(policy(policy_with).send("permitted_attributes_for_#{action}"))
  end
end
