class StaticPagesController < ApplicationController
  def index
    if signed_in?
      if ActiveRecord::Migrator.needs_migration?
        render template: 'static_pages/site_update'
      else
        render template: 'static_pages/logged_in_home'
      end
    else
      render template: 'static_pages/index'
    end
  end

  def unconfirmed
    @user = User.find_by(id: params[:user_id])
    render template: 'static_pages/unconfirmed_index'
  end
end
