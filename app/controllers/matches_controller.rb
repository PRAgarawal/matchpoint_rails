class MatchesController < RestfulController
  include DateHelper

  def index_scope(scope)
    get_requests = params[:requests]
    get_my_matches = params[:my_matches]
    get_past_matches = params[:past_matches]
    sort_order = :asc

    #TODO: These queries may need to be re-examined for performance
    if get_requests == 'true'
      scope = Match.filter_available_matches(scope)
    elsif get_my_matches == 'true'
      scope = current_user.matches.where('matches.match_date >= ?', DateHelper.today_cutoff)
    elsif get_past_matches == 'true'
      scope = Match.filter_past_matches(scope)
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
        # court: {only: [:id, :name]},
        # chat: {only: [:id]},
        # match_users: {only: [:user_id, :is_winner]},
        :court, :chat, :match_users,
        users: {only: [:id, :first_name, :last_name, :skill]}
    ]
  end

  def render_record(match)
    render json: match, include: [
        :court, :chat, :match_users,
        users: {only: [:id, :first_name, :last_name, :skill]}
    ]
  end
end
