class RegistrationsController < Devise::RegistrationsController
  # GET /resource/sign_up?invited_by_code=abcdef
  def new
    super do |resource|
      if session[:invited_by_code].present?
        resource.invited_by_code = session[:invited_by_code]
      else
        session[:invited_by_code] = resource.invited_by_code = params[:invited_by_code]
      end
      @invited_by_code = session[:invited_by_code]

      resource.court_code = params[:court_code]
      @court_code = resource.court_code
    end
  end

  def update
    super do |resource|
      if resource.errors.present?
        render :json => {errors: resource.errors}, :status => :bad_request
      end
    end
  end

  def after_update_path_for(resource)
    user_path(resource)
  end
end
