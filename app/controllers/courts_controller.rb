class CourtsController < RestfulController
  #TODO: Figure out why I can't extend IndexOnlyRestfulController here

  def index_scope(scope)
    get_user_courts = params[:user]

    if get_user_courts == "true"
      scope = User.current_user.courts
    end

    return scope
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
end
