class AssetsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:serve_asset, :serve_home_asset]
  before_filter :authenticate_user!, :except => [:serve_asset, :serve_home_asset]

  def serve_main_asset
    serve_asset_for_app("main")
  end

  protected

  def serve_asset_for_app(app_name)
    path = params[:path]
    respond_to do |format|
      format.html { render :file => "app/assets/matchpoint/#{app_name}/#{path}.html", layout:
          false }
      format.js { render :file => "#{path}.js" }
      format.css { render(:file => "#{path}.css") }
      format.json { render(:file => "app/assets/matchpoint/#{app_name}/#{path}.json") }

      # This is here solely for the purpose of avoiding a routing error when bootstrap.css
      # attempts to find the fonts files. We load the fonts files ourselves in application.css.scss
      format.woff { render :nothing => true }
      format.woff2 { render :nothing => true }
      format.svg { render :nothing => true }
      format.eot { render :nothing => true }
      format.ttf { render :nothing => true }
    end
  end
end
