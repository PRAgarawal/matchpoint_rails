# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Explicitly register the extensions we are interested in compiling
Rails.application.config.assets.precompile.push(
    Proc.new do |path|
      File.extname(path).in? %w(.html .erb .haml .png .gif .jpg .jpeg .eot .otf .svc .woff .woff2 .ttf)
    end)

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( main_app.js )
