class RegistrationsController < Devise::RegistrationsController
  def update
    super do |resource|
      if resource.errors.present?
        render :json => {errors: resource.errors}, :status => :bad_request
        return
      end
    end
  end

  def after_update_path_for(resource)
    user_path(resource)
  end
end
