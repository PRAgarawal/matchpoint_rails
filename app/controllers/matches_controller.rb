class MatchesController < RestfulController
  def index_scope(scope)
    get_requests = params[:requests]
    get_my_matches = params[:my_matches]
    get_past_matches = params[:past_matches]

    scope = scope.group('matches.id')
                .select('array_agg(match_users.user_id) AS user_ids')
                .select('count(match_users) AS num_users')

    if get_requests == 'true'
      scope = scope.where('num_users > (CASE WHEN matches.is_singles THEN 2 ELSE 4 END ')
                  .where('? NOT IN (user_ids)', User.current_user.id)
                  .where('matches.match_date >= now()')
    elsif get_my_matches == 'true'
      scope = scope.where('? IN (user_ids)', User.current_user.id)
                  .where('matches.match_date >= now()')
    elsif get_past_matches == 'true'
      scope = scope.where('? IN (user_ids)', User.current_user.id)
                  .where('matches.match_date < now()')
    end

    return scope
  end

  def join
    match = Match.find(params[:match_id])
    authorize match, :join?

    MatchUser.create!(user_id: User.current_user.id, match_id: match.id)
  end
end
