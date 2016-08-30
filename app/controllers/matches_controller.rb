class MatchesController < RestfulController
  def index_scope(scope)
    get_my_matches = params[:my_matches]
    get_past_matches = params[:past_matches]

    # By default, we get only available (requested) matches
    if get_my_matches == 'true'
      scope = current_user.matches.where('matches.match_date >= CURRENT_DATE')
    elsif get_past_matches == 'true'
      scope = current_user.matches.where('matches.match_date < CURRENT_DATE')
    end

    scope.includes(:court, :users)

    return scope
  end

  def join
    match = Match.find(params[:match_id])
    authorize match, :join?

    MatchUser.create!(user_id: current_user.id, match_id: match.id)
  end

  def leave
    match = Match.find(params[:match_id])
    authorize match, :leave?

    MatchUser.where(user_id: current_user.id, match_id: match.id).first.destroy!
  end

  protected

  def render_records(matches)
    render json: matches, include: [
        :court, users: {only: [:id, :first_name, :last_name, :skill]}]
  end
end
