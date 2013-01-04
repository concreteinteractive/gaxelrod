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


end
