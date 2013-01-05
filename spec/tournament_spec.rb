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
  let(:tournament) { Tournament.new(observer, options) }
  let(:population) {tournament.instance_eval{@population}}
  let(:players) {population.players}


  describe "select_players_for_round" do

    #let(:couples) {tournament.select_players_for_round}

    before do
      Selector.stub(:pick_small_one).and_return(0,1,0,0,0,1)
      @couples = tournament.select_players_for_round
    end

    it "returns an array of arrays with 2 Players each" do
      @couples.each do |couple|
        couple.size.should == 2
        couple.first.should be_a Player
        couple.last.should be_a Player
      end
    end
    it "gets population.size-1 partners for each player, and the player should not be among them" do
      players.each do |player|
        partners = @couples.select{|couple| couple.first == player }
        partners.size.should == 2
        partners.each{|couple| couple.first.should == player}
        partners.map{|p| p.last}.include?(player).should be_false
      end
      @couples.size.should == 6
    end
    it "selects players based on distance" do
      # selection faked with stubbing of Selector.pick_small_one in Before
      playerA = players[0]
      playerB = players[1]
      playerC = players[2]
      @couples[0].last.should == playerB
      @couples[1].last.should == playerC
      @couples[2].last.should == playerA
      @couples[3].last.should == playerA
      @couples[4].last.should == playerA
      @couples[5].last.should == playerB
    end
  end

  describe "reproduce" do

    context "at least 2 different players within fittest array" do
      let(:fittest) { [population[0], population[1], population[1]] }

      it "replaces the population's players" do
        expect {
          tournament.reproduce(fittest)
        }.to change {tournament.instance_eval{@population.players}}
      end
      it "doesn't change the size of the population" do
        expect {
          tournament.reproduce(fittest)
        }.not_to change {tournament.instance_eval{@population.players.size}}
      end
      it "increments @num_generations by 1" do
        expect {
          tournament.reproduce(fittest)
        }.to change { tournament.instance_eval{@num_generations} }.by(1)
      end
    end

    context "player's within fittest array are all identical" do

      let(:fittest) { (0..population.size-1).map{|i| population[0] } }

      it "replaces the population's players" do
        expect {
          tournament.reproduce(fittest)
        }.to change {tournament.instance_eval{@population.players}}
      end
      it "doesn't change the size of the population" do
        expect {
          tournament.reproduce(fittest)
        }.not_to change {tournament.instance_eval{@population.players.size}}
      end
      it "increments @num_generations by 1" do
        expect {
          tournament.reproduce(fittest)
        }.to change { tournament.instance_eval{@num_generations} }.by(1)
      end
    end
  end
end
