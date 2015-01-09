require 'rails_helper'

RSpec.describe SportsController, :type => :controller do
  describe "POST create" do
    it "responds with a 201 status" do
      post :create, sports: FactoryGirl.attributes_for(:sport)
      expect(response.status).to eq 201
    end
  end
  describe "GET show" do
    it "responds with a 200 status" do
      get :show, id: FactoryGirl.create(:sport)
      expect(response.status).to eq 200
    end
  end
  describe "PUT update" do
    let! :sport do
      FactoryGirl.create(:sport)
    end
    it "updates the resource and responds with a 200 status" do
      expect(sport.name).to eq "Basketball"
      put :update, id: sport, sports: { name: "basketball" }
      expect(sport.reload.name).to eq "basketball"
      expect(response.status).to eq 200
    end
  end
  describe "GET index" do
    it "responds with a 200 status" do
      get :index
      expect(response.status).to eq 200
    end
  end
  describe "DELETE destroy" do
    it "responds with a 200 status" do
      sport = FactoryGirl.create(:sport)
      delete :destroy, id: sport
      expect(Sport.find_by(id: sport)).to be_nil
      expect(response.status).to eq 204
    end
  end
end
