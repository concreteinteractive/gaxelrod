require "rspec"
require "player"
require "tournament"

describe "Tournament" do

  let(:observer) do
    obs = Object.new
    obs.stub(:notify_state)
    obs.stub(:notify_end)
    obs
  end
  let(:options) do
    options = {}
    options[:round_length] = 4
    options[:history_length] = 2
    options[:num_players] = 3
    options[:max_generations] = 10
    options
  end
  let(:tournament) {Tournament.new(observer, options)}

  describe "select_players_for_round" do

    it "returns an array of Players" do
      players = tournament.select_players_for_round
      players.first.should be_a Player
    end

  end
end
