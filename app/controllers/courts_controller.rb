class CourtsController < RestfulController
  #TODO: Figure out why I can't extend IndexOnlyRestfulController here

  def index_scope(scope)
    get_joined_courts = params[:joined]

    if get_joined_courts == "true"
      scope = current_user.courts
    elsif get_joined_courts == "false"
      scope = Court.not_joined
    end

    return scope.includes(:postal_address)
  end

  def join
    update_court_membership do |court|
      authorize court, :join?
      CourtUser.create!(user_id: current_user.id, court_id: court.id)
    end
  end

  def leave
    update_court_membership do |court|
      authorize court, :leave?
      CourtUser.where(user_id: current_user.id, court_id: court.id).first.destroy!
    end
  end

  protected

  def update_court_membership
    court = Court.find(params[:court_id])
    if court.present?
      yield court if block_given?
      render nothing: true, status: :no_content
    else
      render nothing: true, status: :not_found
    end
  end

  def render_records(courts)
    render json: courts, include: [:postal_address]
  end
end
