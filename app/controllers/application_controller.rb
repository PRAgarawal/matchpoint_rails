class ApplicationController < ActionController::Base
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :render_403

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :set_csrf_cookie_for_ng
  before_action :set_current_user

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
        :first_name, :last_name, :email, :password, :password_confirmation, :invited_by_code])
    devise_parameter_sanitizer.permit(:sign_in, keys: [
        :email, :password, :remember_me])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:first_name, :last_name, :skill, :password, :password_confirmation, :invitation_token])
  end

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def verified_request?
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
  end

  protected

  def render_403(invalid_exception)
    render json: {error: { detail: "You are not authorized to perform this action" }},
           :status => :forbidden
    logger.info "Authorization errors: #{invalid_exception.inspect}"
  end

  private

  def set_current_user
    User.current_user = current_user
  end
end
