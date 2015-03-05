class ApiController < ApplicationController
  respond_to :json
  # --------------------------------------- @: Huyen  --------------------------------------- #
  # ---------------------------------------
  # d: 15/03/02
  # TODO: Create new user account
  # method: post
  # ---------------------------------------
  def create_user
    render_failed(101,t('missing_param', {obj: 'username'})) and return if params[:username].nil?
    render_failed(101,t('missing_param', {obj: 'type'})) and return if params[:type].nil?
    render_failed(101,t('missing_param', {obj: 'password'})) and return if params[:password].nil?
    render_failed(101, t('missing_param', {obj: 'retype_password'})) and return if params[:retype_password].nil?
    user = User.find_by(username: params[:username])
    render_failed(102, t('invalid_param', {obj: 'username'})) and return unless user.nil?
    render_failed(102, t('invalid_param', {obj: 'retype_password'})) and return if params[:retype_password] != params[:password]
    salt_password = BCrypt::Engine.generate_salt
    password = BCrypt::Engine.hash_secret(params[:password],salt_password)
    begin
      User.transaction do
        user = User.new(
            username: params[:username],
            password: password,
            type: params[:type],
            created_at: Time.now,
            modified_at: Time.now
        )
        user.save!
        profile = Profile.new(
            user_id: user.id,
            firstname: user.username,
            lastname: user.username,
            email: user.username + "@domain.com",
            phone: "username_phone",
            created_at: Time.now,
            modified_at: Time.now
        )
        profile.save!
        render_success(user_id: user.id,username: user.username)
    end
    rescue
      render_failed(202, t('database_error')) and return
    end
  end
  # ---------------------------------------
  # d: 15/03/03
  # TODO: Login
  # method: post
  # ---------------------------------------
  def login
    render_failed(101, t('missing_param', {obj:'username'})) and return if params[:username].nil?
    render_failed(101, t('missing_param', {obj: 'password'})) and return if params[:password].nil?
  end
  # ---------------------------------------
  # d: 15/03/04
  # TODO: Logout
  # method: post
  # ---------------------------------------
  def sign_out

  end
end
