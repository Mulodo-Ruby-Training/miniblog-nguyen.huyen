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
        post :login, {username: "username01", password: "123456"}
        post :change_password, {user_id: 1, current_password: "123456", new_password: "newpass"}
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
        get :get_user_info, {user_id: 1}
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
        post :create_user, FactoryGirl.attributes_for(:param_user,username: "xyzabc" ,password: "123456")
        post :create_user, FactoryGirl.attributes_for(:param_user,username: "username1" ,password: "123456")
        post :create_user, FactoryGirl.attributes_for(:param_user,username: "abcdef1" ,password: "123456")
        post :create_user, FactoryGirl.attributes_for(:param_user,username: "xyztmn1" ,password: "123456")
        get :search_user, keyword: "xyzabc"
        JSON.parse(response.body)["meta"]["status"].should eq(200)
        expect(JSON.parse(response.body)["data"]["list"][0]["username"]).to eq("xyzabc")
      end
    end
  end
end