class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

    def after_sign_in_path_for(resource)
    # If Devise tries to send the user to root_path, send them to home_path instead
    stored_location_for(resource) || root_path
  end
end
