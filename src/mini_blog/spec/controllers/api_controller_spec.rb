require 'rails_helper'
require 'spec_helper'
RSpec.describe ApiController, :type => :controller do
  describe "POST create_user" do
    context "with valid attributes" do
      it "create new user account" do
        expect{ post :create_user, format: :json, :user => {username: "vivian", password: "123456", retype_password: "123456", type: "normal"}}.to change(User,:count)
      end
      it 'responds with 200' do
        expect(response.status).to eq(200)
      end

    end
    context "with invalid attributes" do
      it "does not save new user account" do
        expect{ post :create_user, format: :json, :user => {username: nil, password: "123456", retype_password: "123456", type: "normal"}}.to_not change(User,:count)
      end
      it 'responds with 200' do
        expect(response.status).to_not eq(200)
      end
    end
  end
end
