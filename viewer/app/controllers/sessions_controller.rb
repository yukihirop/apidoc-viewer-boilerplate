class SessionsController < ApplicationController
  def create
    create_session
    redirect_to root_or_origin_url, flash: { success: t('flash.logged_in') }
  end

  def destroy
    reset_session
    redirect_to root_path, flash: { success: t('flash.logged_out') }
  end

  private

  def user
    @user ||= User.find_or_initialize_by(uid: auth.dig(:uid)).tap do |user|
      user.uid           = auth.dig(:uid)
      user.provider      = auth.dig(:provider)
      user.name          = auth.dig(:info, :name)
      user.email         = auth.dig(:info, :email)
      user.first_name    = auth.dig(:info, :first_name)
      user.last_name     = auth.dig(:info, :last_name)
      user.image_url     = auth.dig(:info, :image)
      user.token         = auth.dig(:credentials, :token)
      user.refresh_token = auth.dig(:credentials, :refresh_token)
      user.save!
    end
  end

  def create_session
    session[:refresh_token] = user.refresh_token
  end

  def auth
    request.env['omniauth.auth']
  end

  def root_or_origin_url
    request.env['omniauth.origin'].presence || root_path
  end
end
