require "rspec"
require "population"
require "lattice"
require "player"

describe "Population" do

  let(:population) { Population.new(3, 2) }

  describe "new" do

    let(:lattice_players) { UniqLattice.instance.instance_eval{@players} }

    it "sets @history_length as specified by parameter" do
      population.history_length.should == 2
    end
    it "adds the specified number of players to the @players array" do
      population.players.length.should == 3
      population.players.first.should be_a Player
    end
    it "adds the created players to the Lattice" do
      population.players.each do |player|
        lattice_players[player.id].should_not be_nil
      end
    end
    it "has the Lattice calculate the distances" do
      p1 = population.players.first
      p2 = population.players.last
      UniqLattice.instance.distance_between(p1, p2).should_not be_nil
    end
  end

  describe "replace_players_with" do

    let(:new_players) { (1..3).inject([]) do |players, nr|
        players << Player.create(2)
        players
      end
    }
    let(:lattice_players) { UniqLattice.instance.instance_eval{@players} }

    it "removes the old players from the Lattice" do
      old_players = population.players
      old_players.each do |player|
        lattice_players[player.id].should_not be_nil
      end
      population.replace_players_with(new_players)
      old_players.each do |player|
        lattice_players[player.id].should be_nil
      end
    end
    it "adds the new players" do
      n_p = new_players
      population.replace_players_with(n_p)
      population.players.should == n_p
    end
    it "has the Lattice calculate the distances" do
      p1 = population.players.first
      p2 = population.players.last
      UniqLattice.instance.distance_between(p1, p2).should_not be_nil
    end
  end

  describe "size" do
    it "returns the size of the player's array" do
      population.size.should == population.players.size
    end
  end

  describe "select_fittest" do
    before do
      Selector.stub(:pick_big_one).and_return(0,0,2)
    end
    it "returns an array with the fittest players, as selected by Selector.pick_big_one" do
      fittest = population.select_fittest
      fittest.size.should == population.size
      [0, 0, 2].each do |i|
        fittest.include?(population.players[i]).should be_true
      end
    end
  end

  describe ">" do
    it "returns true if the players array is greater than the compared array's size" do
      (population > [1,2]).should be_true
    end
    it "returns fals if the players array is equal to the compared array's size" do
      (population > [1,2,3]).should be_false
    end
    it "returns fals if the players array is not greater than the compared array's size" do
      (population > [1,2,3,4]).should be_false
    end
  end

  describe "total_score" do
    before do
      Player.any_instance.stub(:score).and_return(3)
    end
    it "returns the sum of the scores of each player" do
      population.total_score.should == 9
    end
  end

  describe "delegated methods" do
    describe "each_index" do
      it "executes the block for each player, yielding its index" do
        player_indices = []
        population.each_index { |i| player_indices << i }
        player_indices.should == [0, 1, 2]
      end
    end
    describe "each" do
      it "executes the block for each player" do
        player_ids = []
        population.each { |p| player_ids << p.id }
        player_ids.should == population.players.map { |p| p.id }
      end
    end
    describe "[]" do
      it "returns the player with the specified index" do
        population[0].should == population.players[0]
      end
      it "returns the players specified by the range" do
        population[1..-1].should == population.players[1..-1]
      end
    end
  end

  describe "private method scores" do
    it "returns an array with the scores of the players" do
      population.send(:scores).should == [0, 0, 0]
    end
  end

end
