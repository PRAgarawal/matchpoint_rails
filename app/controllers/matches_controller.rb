class MatchesController < RestfulController
  def index_scope(scope)
    get_requests = params[:requests]
    get_my_matches = params[:my_matches]
    get_past_matches = params[:past_matches]

    scope = scope.joins(:match_users)
                .select('matches.*')
                .group('matches.id')

    #TODO: These queries may need to be re-examined for performance
    if get_requests == 'true'
      scope = scope.where('(SELECT count(users.id) FROM users WHERE users.id = match_users.user_id) < ' +
                            '(CASE WHEN matches.is_singles THEN 2 ELSE 4 END)')
                  .where('? != ANY (SELECT id FROM users WHERE users.id = match_users.user_id)',
                         User.current_user.id)
                  .where('matches.match_date >= CURRENT_DATE')
    elsif get_my_matches == 'true'
      scope = scope.where('? = ANY (SELECT id FROM users WHERE users.id = match_users.user_id)',
                          User.current_user.id)
                  .where('matches.match_date >= CURRENT_DATE')
    elsif get_past_matches == 'true'
      scope = scope.where('? = ANY (SELECT id FROM users WHERE users.id = match_users.user_id)',
                          User.current_user.id)
                  .where('matches.match_date < CURRENT_DATE')
    end

    return scope
  end

  def join
    match = Match.find(params[:match_id])
    authorize match, :join?

    MatchUser.create!(user_id: User.current_user.id, match_id: match.id)
  end
end
