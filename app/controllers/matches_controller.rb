class MatchesController < RestfulController
  def index_scope(scope)
    get_requests = params[:requests]
    get_my_matches = params[:my_matches]
    get_past_matches = params[:past_matches]

    scope = scope.select('matches.*')
                .joins(:match_users)
                .group('matches.id')
    sort_order = :asc

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
      sort_order = :desc
    end

    return scope.order(match_date: sort_order)
  end

  def join
    update_match_membership do |match|
      authorize match, :join?
      MatchUser.create!(user_id: current_user.id, match_id: match.id) if match.present?
    end
  end

  def leave
    update_match_membership do |match|
      authorize match, :leave?
      MatchUser.where(user_id: current_user.id, match_id: match.id).first.destroy! if match.present?
    end
  end

  protected

  def update_match_membership
    match = Match.find_by(id: params[:match_id])
    yield match if block_given?
    if match.present?
      render nothing: true, status: :no_content
    else
      render nothing: true, status: :not_found
    end
  end

  def render_records(matches)
    render json: matches, include: [
        :court, :chat,
        users: {only: [:id, :first_name, :last_name, :skill]}
    ]
  end
end
