class RegistrationsController < Devise::RegistrationsController
  # GET /resource/sign_up?invited_by_code=abcdef
  def new
    super do |resource|
      resource.invited_by_code = params[:invited_by_code]
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
