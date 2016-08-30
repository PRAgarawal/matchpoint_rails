class MatchesController < RestfulController
  def index_scope(scope)
    get_requests = params[:requests]
    get_my_matches = params[:my_matches]
    get_past_matches = params[:past_matches]

    scope = scope.select('matches.*')
                .joins(:match_users)
                .group('matches.id')

    #TODO: These queries may need to be re-examined for performance
    if get_requests == 'true'
      scope = scope.where('matches.match_date >= CURRENT_DATE')
                  .having('MAX(CASE WHEN match_users.user_id = ? THEN 1 ELSE 0 END) = 0',
                          User.current_user.id)
                  .having('COUNT(match_users.id) < (CASE WHEN matches.is_singles THEN 2 ELSE 4 END)')
    elsif get_my_matches == 'true'
      scope = current_user.matches.where('matches.match_date >= CURRENT_DATE')
    elsif get_past_matches == 'true'
      scope = current_user.matches.where('matches.match_date < CURRENT_DATE')
    end

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
