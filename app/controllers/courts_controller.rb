class CourtsController < RestfulController
  include StringHelper
  #TODO: Figure out why I can't extend IndexOnlyRestfulController here

  def index_scope(scope)
    get_joined_courts = params[:joined]
    get_unconfirmed = params[:unconfirmed]

    if get_joined_courts == "true"
      scope = current_user.courts
    elsif get_joined_courts == "false"
      scope = Court.not_joined
    elsif get_unconfirmed == "true"
      scope = scope.where(is_confirmed: false)
    end

    if params[:is_dfw].present?
      scope = scope.where(is_dfw: to_boolean(params[:is_dfw]))
    end

    return scope.includes(:postal_address)
  end

  def join
    update_court_membership do |court|
      authorize court, :join?
      CourtUser.create!(user_id: current_user.id, court_id: court.id) if court.present?
    end
  end

  def leave
    update_court_membership do |court|
      authorize court, :leave?
      CourtUser.where(user_id: current_user.id, court_id: court.id).first.destroy! if court.present?
    end
  end

  protected

  def update_court_membership
    court = Court.find_by(id: params[:court_id])
    yield court if block_given?
    if court.present?
      render nothing: true, status: :no_content
    else
      render nothing: true, status: :not_found
    end
  end

  def render_records(courts)
    render json: courts, include: [:postal_address]
  end
end
