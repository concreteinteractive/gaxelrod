require 'spec_helper'

describe SimulationController do

  describe "GET 'start'" do
    it "returns http success" do
      get 'start'
      response.should be_success
    end
  end

  describe "GET 'next'" do
    it "returns http success" do
      get 'next'
      response.should be_success
    end
  end

end
