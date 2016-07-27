class StaticPagesController < ApplicationController
  # skip_before_action :authenticate_user!

  def index
    # if signed_in?
    #   if ActiveRecord::Migrator.needs_migration?
    #     render template: "static_pages/site_update"
    #   else
        render template: "static_pages/logged_in_home"
    #   end
    # else
    #   redirect_to '/users/sign_up'
    # end
  end

  def unconfirmed
    render template: "static_pages/unconfirmed_index"
  end
end
