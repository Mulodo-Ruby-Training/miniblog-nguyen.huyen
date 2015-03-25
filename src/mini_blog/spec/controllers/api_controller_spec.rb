require 'rails_helper'
require 'spec_helper'
require "bcrypt"
RSpec.describe ApiController, :type => :controller do
  describe "POST create_user" do
    context "with valid attributes" do
      it "create new user account" do
        @user =  FactoryGirl.attributes_for(:param_user)
        post :create_user,@user
        Profile.count.should eq(1)
        User.count.should eq(1)
      end
      it 'responds with status: 200' do
        @user =  FactoryGirl.attributes_for(:param_user)
        post :create_user, @user
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(200)
      end
    end
    context "with invalid attributes" do
      it "failed with status 101 if missing param username " do
        @user = FactoryGirl.attributes_for(:param_user, username: nil )
        post :create_user,@user
        User.count.should eq(0)
        Profile.count.should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param user_type " do
        @user = FactoryGirl.attributes_for(:param_user, user_type: nil )
        post :create_user, @user
        User.count.should eq(0)
        Profile.count.should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param password " do
        @user =  FactoryGirl.attributes_for(:param_user, password: nil )
        post :create_user, @user
        User.count.should eq(0)
        Profile.count.should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param retype_password " do
        post :create_user, FactoryGirl.attributes_for(:param_user, retype_password: nil )
        User.count.should eq(0)
        Profile.count.should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 102 if confirm password does not match " do
        post :create_user, FactoryGirl.attributes_for(:param_user, password: "123456", retype_password: "abcdef" )
        User.count.should eq(0)
        Profile.count.should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(102)
      end
      it "failed with status 102 if username's existed " do
        FactoryGirl.create(:user, username: "username01")
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01" )
        User.count.should eq(1)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(102)
      end
    end
  end
  describe "POST Login" do
    context "with valid attributes" do
      it "create new session" do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", token: nil)
        post :login, {username: "username01", password: "123456"}
        expect(session[:token]).to eq(JSON.parse(response.body)["data"]["token"])
      end
      it 'responds with status: 200' do
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", token: nil)
        post :login, {username: "username01", password: "123456"}
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(200)
      end
    end
    context "with invalid attributes" do
      it "failed with status 101 if missing param username " do
        post :login, {username: nil, password: "123456"}
        session[:token].should eq(nil)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param password " do
        post :login, {username: "username01", password: nil}
        session[:token].should eq(nil)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 102 if username's not exiting " do
        post :login, {username: "username01", password: "abcdef"}
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(102)
      end
      it "failed with status 102 if password does not match " do
        FactoryGirl.create(:user, username: "username01", password: "123456")
        post :login, {username: "username01", password: "abcdef"}
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(102)
      end
    end
  end
  describe "POST Logout" do
    context "with valid attributes" do
      it "destroy all session" do
        FactoryGirl.create(:user, username: "username01", password: "123456")
        post :login, {username: "username01", password: "123456"}
        post :sign_out
        session[:token].should eq(nil)
        JSON.parse(response.body)["meta"]["status"].should eq(200)
        expect(JSON.parse(response.body)["data"]["token"]).to eq(nil)
      end
    end
  end
  describe "POST Change_password" do
    context "with valid attributes" do
      it "Update user's password" do
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456")
        user_id = post_id = JSON.parse(response.body)["data"]["id"]
        post :login, {username: "username01", password: "123456"}
        post :change_password, {user_id: user_id, current_password: "123456", new_password: "newpass"}
        post :sign_out
        post :login, {username: "username01", password: "newpass"}
        JSON.parse(response.body)["meta"]["status"].should eq(200)
        expect(session[:token]).to eq(JSON.parse(response.body)["data"]["token"])
      end
    end
    context "with invalid attributes" do
      it "failed with status 101 if missing param user_id " do
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456")
        post :login, {username: "username01", password: "123456"}
        post :change_password, {user_id: nil, current_password: "123456", new_password: "newpass"}
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param current_password " do
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456")
        post :login, {username: "username01", password: "123456"}
        post :change_password, {user_id: 1, current_password: nil, new_password: "newpass"}
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param new_password " do
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456")
        post :login, {username: "username01", password: "123456"}
        post :change_password, {user_id: 1, current_password: "123456", new_password: nil}
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 301 if user not login " do
        FactoryGirl.create(:user, username: "username01", password: "123456")
        session[:token] = nil
        post :change_password, {user_id: 1, current_password: "123456", new_password: "newpass"}
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(301)
      end
      it "failed with status 102 if current_password dose not match " do
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456")
        post :login, {username: "username01", password: "123456"}
        post :change_password, {user_id: 1, current_password: "newpass", new_password: "newpass"}
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(102)
      end
    end
  end
  #==========================================================================
  describe "POST update_user_info" do
    context "with valid attributes" do
      it "update user's info" do
        post :create_user, FactoryGirl.attributes_for(:param_user, user_id: 1, password: "123456")
        post :login, {username: "username01", password: "123456"}
        post :update_user_info, FactoryGirl.attributes_for(:user_info, email: "useremail@example.com")
        JSON.parse(response.body)["meta"]["status"].should eq(200)
        expect(JSON.parse(response.body)["data"]["email"]).to eq("useremail@example.com")
      end
    end
    context "with invalid attributes" do
      it "failed with status 101 if missing param user_id " do
        FactoryGirl.create(:user, username: "username01", password: "123456")
        post :login, {username: "username01", password: "123456"}
        post :update_user_info, FactoryGirl.attributes_for(:user_info, user_id: nil)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 301 if user not login " do
        FactoryGirl.create(:user, username: "username01", password: "123456")
        session[:token] = nil
        post :update_user_info, FactoryGirl.attributes_for(:user_info)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(301)
      end
    end
  end
  #===============================================================================
  describe "GET update_user_info" do
    context "with valid user_id" do
      it "get user's info" do
        post :create_user, FactoryGirl.attributes_for(:param_user, password: "123456")
        user_id = JSON.parse(response.body)["data"]["id"]
        get :get_user_info, {user_id: user_id}
        JSON.parse(response.body)["meta"]["status"].should eq(200)
        expect(JSON.parse(response.body)["data"]["email"]).to eq("username01@domain.com")
      end
    end
    context "with invalid attributes" do
      it "failed with status 101 if missing param user_id " do
        FactoryGirl.create(:user, username: "username01", password: "123456")
        get :get_user_info, {user_id: nil}
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
    end
  end
  #=================================================================================
  describe "GET search_user" do
    context "get list search user" do
      it "show search result " do
        post :create_user, FactoryGirl.attributes_for(:param_user,username: "username" ,password: "123456")
        post :create_user, FactoryGirl.attributes_for(:param_user,username: "abcdef" ,password: "123456")
        post :create_user, FactoryGirl.attributes_for(:param_user,username: "xyz abc" ,password: "123456")
        post :create_user, FactoryGirl.attributes_for(:param_user,username: "username1" ,password: "123456")
        post :create_user, FactoryGirl.attributes_for(:param_user,username: "abcdef1" ,password: "123456")
        post :create_user, FactoryGirl.attributes_for(:param_user,username: "xyztmn1" ,password: "123456")
        get :search_user, keyword: "xyz"
        JSON.parse(response.body)["meta"]["status"].should eq(200)
        expect(JSON.parse(response.body)["data"]["list"][0]["username"]).to eq("xyz abc")
      end
    end
  end
  #=================================================================================
  describe "POST create_post" do
    context "with valid attributes" do
      it "create new post" do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", token: nil)
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        Post.count.should eq(1)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(200)
      end
    end
    context "with invalid attributes" do
      it "failed with status 101 if missing param token " do
        post :create_post,FactoryGirl.attributes_for(:params_post, token: nil )
        Post.count.should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param title " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", token: nil)
        post :login, {username: "username01", password: "123456"}
        post :create_post,FactoryGirl.attributes_for(:params_post, token: session[:token], title: nil )
        Post.count.should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param short_description " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", token: nil)
        post :login, {username: "username01", password: "123456"}
        post :create_post,FactoryGirl.attributes_for(:params_post, token: session[:token], short_description: nil )
        Post.count.should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param content " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", token: nil)
        post :login, {username: "username01", password: "123456"}
        post :create_post,FactoryGirl.attributes_for(:params_post, token: session[:token], content: nil )
        Post.count.should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
    end
  end
  #=======================================================================================
  describe "POST change status of post" do
    context "with valid attributes" do
      it "change status of post" do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :change_status_of_post,{token: session[:token], post_id: post_id,status: 0 }
        JSON.parse(response.body)["data"]["status"].should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(200)
      end
    end
    context "with invalid attributes" do
      it "failed with status 101 if missing param token " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :change_status_of_post,{token: nil, post_id: post_id,status: 0 }
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param post_id " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post :change_status_of_post,{token: session[:token], post_id: nil,status: 0 }
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param status " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :change_status_of_post,{token: session[:token], post_id: post_id,status: nil }
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
    end
  end
  #=======================================================================================
  describe "POST update post" do
    context "with valid attributes" do
      it "update post" do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :update_post,{token: session[:token], post_id: post_id,title: "new title" }
        JSON.parse(response.body)["data"]["title"].should eq("new title")
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(200)
      end
    end
    context "with invalid attributes" do
      it "failed with status 101 if missing param token " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post :update_post,{token: nil, post_id: 1,title: "new title" }
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param post_id " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post :update_post,{token: session[:token], post_id: nil,title: "new title" }
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 102 if permission denied " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username02", password: "123456")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post :sign_out
        post :login, {username: "username02", password: "123456"}
        post :update_post,{token: session[:token], post_id: 1,title: "new title" }
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(102)
      end
    end
  end
  #=========================================================================
  describe "POST delete post" do
    context "with valid attributes" do
      it "delete post" do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :delete_post,{token: session[:token], post_id: post_id }
        Post.count.should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(200)
      end
    end
    context "with invalid attributes" do
      it "failed with status 101 if missing param token " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post :delete_post,{token: nil, post_id: 1 }
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param post_id " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post :delete_post,{token: session[:token], post_id: nil }
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 102 if permission denied " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username02", password: "123456")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post :sign_out
        post :login, {username: "username02", password: "123456"}
        post :delete_post,{token: session[:token], post_id: 1 }
        Post.count.should eq(1)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(102)
      end
    end
  end
  describe "GET get all posts" do
    context "get all posts" do
      it "show all posts" do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post :create_post,{token: session[:token], title: "title2", short_description: "short description",content: "content" }
        get :get_all_posts
        (JSON.parse(response.body)["data"]["total"]).should eq(2)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(200)
      end
    end
  end
  describe "GET get all posts for user" do
    context "get all posts for user" do
      it "show all posts for a user" do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        user_id = JSON.parse(response.body)["data"]["id"]
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post :create_post,{token: session[:token], title: "title2", short_description: "short description",content: "content" }
        get :get_all_posts_for_user,{user_id: user_id}
        (JSON.parse(response.body)["data"]["total"]).should eq(2)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(200)
      end
    end
  end
  #================================================================================================
  describe "POST create comment" do
    context "with valid attributes" do
      it "create new comment" do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :create_comment,{token: session[:token], post_id: post_id,content: "comment" }
        Comment.count.should eq(1)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(200)
      end
    end
    context "with invalid attributes" do
      it "failed with status 101 if missing param token " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post :create_comment,{token: nil, post_id: 1,content: "comment" }
        Comment.count.should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param post_id " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post :create_comment,{token: session[:token], post_id: nil,content: "comment" }
        Comment.count.should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param content " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :create_comment,{token: session[:token], post_id: post_id,content: nil }
        Comment.count.should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
    end
  end
  #===========================================================================
  describe "POST update comment" do
    context "with valid attributes" do
      it "update comment" do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :create_comment,{token: session[:token], post_id: post_id,content: "comment" }
        comment_id = JSON.parse(response.body)["data"]["id"]
        post :update_comment,{token: session[:token],comment_id: comment_id, content: "new content comment" }
        JSON.parse(response.body)["data"]["content"].should eq("new content comment")
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(200)
      end
    end
    context "with invalid attributes" do
      it "failed with status 101 if missing param token " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post :create_comment,{token: session[:token], post_id: 1,content: "comment" }
        post :update_comment,{token: nil ,comment_id: 1, content: "new content comment" }
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param comment_id " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post :create_comment,{token: session[:token], post_id: 1,content: "comment" }
        post :update_comment,{token: session[:token],comment_id: nil, content: "new content comment" }
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 102 if permission denied " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username02", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :create_comment,{token: session[:token],post_id: post_id,content: "comment" }
        comment_id = JSON.parse(response.body)["data"]["id"]
        post :sign_out
        post :login, {username: "username02", password: "123456"}
        post :update_comment,{token: session[:token], comment_id: comment_id, content: "new content comment" }
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(102)
      end
    end
  end
  #===============================================================================
  describe "POST delete comment" do
    context  "with valid attributes" do
      it "delete comment" do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :create_comment,{token: session[:token], post_id: post_id,content: "comment" }
        comment_id = JSON.parse(response.body)["data"]["id"]
        post :delete_comment,{token: session[:token],comment_id: comment_id }
        Comment.count.should eq(0)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(200)
      end
    end
    context  "with invalid attributes" do
      it "failed with status 101 if missing param token " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :create_comment,{token: session[:token], post_id: post_id,content: "comment" }
        post :delete_comment,{token: nil,comment_id: 1 }
        Comment.count.should eq(1)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 101 if missing param comment_id " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :create_comment,{token: session[:token], post_id: post_id,content: "comment" }
        post :delete_comment,{token: session[:token],comment_id: nil }
        Comment.count.should eq(1)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(101)
      end
      it "failed with status 102 if permission denied " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username02", password: "123456", user_type: "normal")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :create_comment,{token: session[:token], post_id: post_id,content: "comment" }
        comment_id = JSON.parse(response.body)["data"]["id"]
        post :sign_out
        post :login, {username: "username02", password: "123456"}
        post :delete_comment,{token: session[:token],comment_id: comment_id }
        Comment.count.should eq(1)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(102)
      end
    end
  end
  #=====================================================================================
  describe "GET get all comments for a post" do
    context  "with invalid attributes" do
      it "show list comments of post " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :create_comment,{token: session[:token], post_id: post_id,content: "comment" }
        post :create_comment,{token: session[:token], post_id: post_id,content: "comment2" }
        post :get_all_comments_for_post,{post_id: post_id }
        JSON.parse(response.body)["data"]["total"].should eq(2)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(200)
      end
    end
  end
  #=====================================================================================
  describe "GET get all comments for a user" do
    context  "with invalid attributes" do
      it "show list comments of post " do
        session[:token] = nil
        post :create_user, FactoryGirl.attributes_for(:param_user, username: "username01", password: "123456", user_type: "admin")
        user_id = JSON.parse(response.body)["data"]["id"]
        post :login, {username: "username01", password: "123456"}
        post :create_post,{token: session[:token], title: "title", short_description: "short description",content: "content" }
        post_id = JSON.parse(response.body)["data"]["id"]
        post :create_comment,{token: session[:token], post_id: post_id,content: "comment" }
        post :create_comment,{token: session[:token], post_id: post_id,content: "comment2" }
        post :get_all_comments_for_user,{user_id: user_id }
        JSON.parse(response.body)["data"]["total"].should eq(2)
        expect(JSON.parse(response.body)["meta"]["status"]).to eq(200)
      end
    end
  end
end