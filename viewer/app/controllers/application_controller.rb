class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?

  private

  def current_user
    return unless session[:refresh_token]
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(refresh_token: session[:refresh_token])
  rescue ActiveRecord::RecordNotFound
    reset_session
    nil
  end

  def logged_in?
    current_user.present?
  end
end
