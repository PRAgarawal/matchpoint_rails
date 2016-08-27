class CourtsController < RestfulController
  #TODO: Figure out why I can't extend IndexOnlyRestfulController here

  def index_scope(scope)
    get_joined_courts = params[:joined]

    if get_joined_courts == "true"
      scope = User.current_user.courts
    elsif get_joined_courts == "false"
      scope = Court.not_joined
    end

    return scope.includes(:postal_address)
  end

  def join
    court = Court.find(params[:court_id])
    authorize court, :join?

    CourtUser.create!(user_id: User.current_user.id, court_id: court.id)
  end

  def leave
    court = Court.find(params[:court_id])
    authorize court, :leave?

    CourtUser.where(user_id: User.current_user.id, court_id: court.id).first.destroy!
  end

  protected

  def render_records(courts)
    render json: courts, include: [:postal_address]
  end
end
