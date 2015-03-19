class ApiController < ApplicationController
  respond_to :json
  skip_before_filter :verify_authenticity_token
  # --------------------------------------- @: Huyen  --------------------------------------- #
  # ---------------------------------------
  # d: 15/03/02
  # TODO: Create new user account
  # method: post
  # ---------------------------------------
  def create_user
    render_failed(101,t('missing_param',:param =>'username')) and return if params[:username].nil?
    render_failed(101,t('missing_param', :param => 'user_type')) and return if params[:user_type].nil?
    render_failed(101,t('missing_param', :param => 'password')) and return if params[:password].nil?
    render_failed(101,t('missing_param',:param => 'retype_password')) and return if params[:retype_password].nil?
    user = User.find_by(username: params[:username])
    render_failed(102,t('invalid_param',:param => 'username')) and return unless user.nil?
    render_failed(102,t('invalid_param',:param => 'retype_password')) and return if params[:retype_password] != params[:password]
    begin

      user = User.new(
          username: params[:username],
          user_type: params[:user_type],
          created_at: Time.now,
          modified_at: Time.now
      )
      user.create_password(params[:password])
      user.save!
      user.build_profile
      render_success(user, t('create_user_success'))

    rescue
      render_failed(202, t('database_error'))
    end
  end
  # ---------------------------------------
  # d: 15/03/03
  # TODO: Login
  # method: post
  # ---------------------------------------
  def login
    render_failed(302, t('existing_token')) and return unless session[:token].nil?
    render_failed(101, t('missing_param', {:param =>'username'})) and return if params[:username].nil?
    render_failed(101, t('missing_param', {:param =>'password'})) and return if params[:password].nil?
    user = User.find_by(username: params[:username])
    render_failed(102,t('invalid_param',:param => 'username')) and return if user.nil?
    render_failed(102,t('invalid_param',:param => 'password')) and return unless user.check_password(params[:password])
    user.update_token
    user.save!
    session[:token] = user.token
    render_success(user, t('login_success'))
  end
  # ---------------------------------------
  # d: 15/03/04
  # TODO: Logout
  # method: post
  # ---------------------------------------
  def sign_out
    user = User.find_by(token: session[:token])
    session[:token] = nil
    render_failed(102,t('invalid_param',:param => 'user')) and return if user.nil?
    user.token = nil
    user.save!
    hash = {token: user.token}
    render_success(hash, t('logout_success'))
  end
  # ---------------------------------------
  # d: 15/03/07
  # TODO: Change user's password
  # method: post
  # ---------------------------------------
  def change_password
    render_failed(101, t('missing_param', {:param =>'user_id'})) and return if params[:user_id].nil?
    user = User.find_by(params[:user_id])
    render_failed(102,t('invalid_param',:param => 'user_id')) and return if user.nil?
    render_failed(301, t('not_login')) and return unless user.signed_in?
    render_failed(101, t('missing_param', {:param =>'current_password'})) and return if params[:current_password].nil?
    render_failed(101, t('missing_param', {:param =>'new_password'})) and return if params[:new_password].nil?
    render_failed(102,t('invalid_param',:param => 'current_password')) and return unless user.check_password(params[:current_password])
    begin
      user.create_password(params[:new_password])
      user.modified_at = Time.now
      user.save!
      hash = {:user_id => user.id,
              :password => user.password
        }
      render_success(hash, t('change_password_success'))
    rescue
      render_failed(202, t('database_error'))
    end
  end
  # ---------------------------------------
  # d: 15/03/07
  # TODO: Update user's info
  # method: post
  # ---------------------------------------
  def update_user_info
    render_failed(101, t('missing_param', {:param =>'user_id'})) and return if params[:user_id].nil?
    user = User.find_by(params[:user_id])
    render_failed(102,t('invalid_param',:param => 'user_id')) and return if user.nil?
    render_failed(301, t('not_login')) and return unless user.signed_in?
    begin
      user.update!(modified_at: Time.now)
      profile = Profile.find_by(user_id: user.id)
      profile.first_name = params[:first_name] unless params[:first_name].nil?
      profile.last_name = params[:last_name] unless params[:last_name].nil?
      profile.email = params[:email] unless params[:email].nil?
      profile.phone = params[:phone] unless params[:phone].nil?
      profile.modified_at = Time.now
      profile.save!
      user.save!
      image = Image.find_by(subject_type: "avatar", subject_id: profile.id)
      if !image.nil?
        image.url = params[:avatar] unless params[:avatar].nil?
        image.modified_at = Time.now
        image.save!
      elsif !params[:avatar].nil?
        image  = Image.new(
            subject_id: profile.id,
            subject_type: "avatar",
            name: "avatar_"+user.username,
            url: params[:avatar],
            created_at: Time.now,
            modified_at: Time.now
        )
        image.save!
      end
      hash = {
          :user_id => user.id,
          :first_name => profile.first_name,
          :last_name => profile.last_name,
          :email => profile.email,
          :avatar => image.url
      }
      render_success(hash, t('update_user_info_success'))

    rescue
      render_failed(202, t('database_error'))
    end
  end
  # ---------------------------------------
  # d: 15/03/08
  # TODO: Get user's info
  # method: get
  # ---------------------------------------
  def get_user_info
    render_failed(101, t('missing_param', {:param =>'user_id'})) and return if params[:user_id].nil?
    user = User.find_by(params[:user_id])
    render_failed(102,t('invalid_param',:param => 'user_id')) and return if user.nil?
    profile = Profile.find_by(user_id: user.id)
    image = Image.find_by(subject_type: "avatar", subject_id: profile.id)
    avatar = nil
    avatar = image.url unless image.nil?
    begin
    hash = {
        :user_id => user.id,
        :user_type => user.user_type,
        :username => user.username,
        :gender => profile.gender,
        :address => profile.address,
        :birth_day => profile.birth_day,
        :phone => profile.phone,
        :created_at => user.created_at,
        :modified_at => user.modified_at,
        :first_name => profile.first_name,
        :last_name => profile.last_name,
        :email => profile.email,
        :avatar => avatar
    }
    render_success(hash, t('get_user_info_success'))
    rescue
      render_failed(202, t('database_error'))
    end
  end
  # ---------------------------------------
  # d: 15/03/11
  # TODO: Search user
  # method: get
  # ---------------------------------------
  def search_user
    hash = {}
    limit =20
    limit = params[:limit] unless params[:limit].nil?
    order = "id"
    order = params[:order] unless params[:order].nil?
    page = params[:page].to_i > 0 ? params[:page].to_i.abs : 1
    begin
      hash = User.search(params[:keyword],page,limit,order)
      render_success(hash, t('search_success'))
    rescue
      render_failed(202, t('database_error'))
    end
  end
  # ---------------------------------------
  # d: 15/03/17
  # TODO: Create post
  # method: post
  # ---------------------------------------
  def create_post
    render_failed(101, t('missing_param', {:param =>'token'})) and return if params[:token].nil?
    user = User.find_by(token: params[:token])
    render_failed(102, t('invalid_param',:param => 'token')) and return if user.nil?
    render_failed(301, t('not_login')) and return unless user.signed_in?
    render_failed(101, t('missing_param', {:param =>'title'})) and return if params[:title].nil?
    render_failed(101, t('missing_param', {:param =>'short_description'})) and return if params[:short_description].nil?
    render_failed(101, t('missing_param', {:param =>'content'})) and return if params[:content].nil?
    begin
      post = Post.new(
          user_id: user.id,
          title: params[:title],
          short_description: params[:short_description],
          content: params[:content],
          created_at: Time.now,
          modified_at: Time.now
      )
      post.save!
      unless params[:image].nil?
        num = 0
        params[:image].each {|image|
          post_image = Image.new(
              subject_id: post.id,
              subject_type: "post_image" ,
              name: "post_image_" + post.id.to_s + "_" + (num+1).to_s,
              url: image,
              created_at: Time.now,
              modified_at: Time.now
          )
          num += 1
          post_image.save!
        }
      end
      render_success(post, t('create_post_success'))
    rescue
      render_failed(202, t('database_error'))
    end
  end
  # ---------------------------------------
  # d: 15/03/17
  # TODO: Active or deactive post
  # method: post
  # ---------------------------------------
  def change_status_of_post
    render_failed(101, t('missing_param', {:param =>'token'})) and return if params[:token].nil?
    user = User.find_by(token: params[:token])
    render_failed(102, t('invalid_param',:param => 'token')) and return if (user.nil? || user.user_type != "admin")
    render_failed(301, t('not_login')) and return unless user.signed_in?
    render_failed(101, t('missing_param', {:param =>'post_id'})) and return if params[:post_id].nil?
    post = Post.find_by(params[:post_id])
    render_failed(102, t('invalid_param',:param => 'post_id')) and return if post.nil?
    render_failed(101, t('missing_param', {:param =>'status'})) and return if params[:status].nil?
    begin
      post.status = params[:status]
      post.save!
      hash = {
          :post_id => post.id,
          :user_id => post.user_id,
          :title => post.title,
          :status => post.status
      }
      render_success(hash, t('update_post_status_success'))
    rescue
      render_failed(202, t('database_error'))
    end
  end
  # ---------------------------------------
  # d: 15/03/17
  # TODO: Update post
  # method: post
  # ---------------------------------------
  def update_post
    render_failed(101, t('missing_param', {:param =>'token'})) and return if params[:token].nil?
    user = User.find_by(token: params[:token])
    render_failed(102, t('invalid_param',:param => 'token')) and return if user.nil?
    render_failed(301, t('not_login')) and return unless user.signed_in?
    render_failed(101, t('missing_param', {:param =>'post_id'})) and return if params[:post_id].nil?
    post = Post.find_by(params[:post_id])
    render_failed(102, t('invalid_param',:param => 'post_id')) and return if post.nil?
    render_failed(102, t('permission_denied')) and return unless post.user_id == user.id
    begin
      post.title = params[:title] unless params[:title].nil?
      post.short_description = params[:short_description] unless params[:short_description].nil?
      post.content = params[:content] unless params[:content].nil?
      post.modified_at = Time.now
      post.save!
      render_success(post,t('update_post_success'))
    rescue
      render_failed(202, t('database_error'))
    end
  end
  # ---------------------------------------
  # d: 15/03/17
  # TODO: Delete post
  # method: post
  # ---------------------------------------
  def delete_post
    render_failed(101, t('missing_param', {:param =>'token'})) and return if params[:token].nil?
    user = User.find_by(token: params[:token])
    render_failed(102, t('invalid_param',:param => 'token')) and return if user.nil?
    render_failed(301, t('not_login')) and return unless user.signed_in?
    render_failed(101, t('missing_param', {:param =>'post_id'})) and return if params[:post_id].nil?
    post = Post.find_by(params[:post_id])
    render_failed(102, t('invalid_param',:param => 'post_id')) and return if post.nil?
    render_failed(102, t('permission_denied')) and return unless post.user_id == user.id
    begin
      images = Image.find_by(subject_id: post.id, subject_type: "post_image")
      images.destroy! unless images.nil?
      post.destroy!
      render_success(nil, t('delete_post_success'))
    rescue
      render_failed(202, t('database_error'))
    end
  end
  # ---------------------------------------
  # d: 15/03/17
  # TODO: Get all posts
  # method: get
  # ---------------------------------------
  def get_all_posts
    limit = 20
    limit = params[:limit] unless params[:limit].nil?
    order ="id"
    order = params[:order] unless params[:order].nil?
    page = params[:page].to_i > 0 ? params[:page].to_i.abs : 1
    begin
      posts = Post.search("",page,limit,order)
      render_success(posts, t('get_all_posts_success'))
    rescue
      render_failed(202, t('database_error'))
    end
  end
  # ---------------------------------------
  # d: 15/03/17
  # TODO: Get all posts for user
  # method: get
  # ---------------------------------------
  def get_all_posts_for_user
    render_failed(101, t('missing_param', {:param =>'user_id'})) and return if params[:user_id].nil?
    user = User.find_by(params[:user_id])
    render_failed(102,t('invalid_param',:param => 'user_id')) and return if user.nil?
    limit = 20
    limit = params[:limit] unless params[:limit].nil?
    order ="id"
    order = params[:order] unless params[:order].nil?
    page = params[:page].to_i > 0 ? params[:page].to_i.abs : 1
    begin
      posts = Post.search("",page, limit, order, params[:user_id])
      render_success(posts, t('get_all_posts_for_user_success'))
    rescue
      render_failed(202, t('database_error'))
    end
  end

end
