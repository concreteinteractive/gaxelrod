require "rspec"
require "lattice"
require "selector"
require "player"
require "chromosome"

describe "Player" do
  describe "class methods" do
    describe "Player.next_id" do
      before do
        Player.instance_eval{@@current_player_id = 0}
      end

      it "increments the class variable current_player_id and returns it" do
        Player.next_id.should == 1
        Player.instance_eval{@@current_player_id}.should == 1

        Player.next_id.should == 2
        Player.instance_eval{@@current_player_id}.should == 2
      end
    end

    describe "create" do

      let(:player){Player.create(2)}

      it "creates a player" do
        player.should be_a Player
      end
      it "gives the created player a filled chromosome" do
        player.chromosome.should be_a Chromosome
        player.chromosome.size > 0
      end
      it "sets x and y" do
        player.x.should satisfy{|x| x>=0 && x<=1}
        player.y.should satisfy{|y| y>=0 && y <=1}
      end
      it "adds the player to the Lattice" do
        UniqLattice.instance.should_receive(:add).with(player)
      end
    end

    describe "reproduce_from" do

      let(:chr1)do
        chr = []
        8.times { chr << Action.random_action }
        chr
      end
      let(:chr2) do
        chr = []
        8.times { chr << Action.random_action }
        chr
      end
      let(:playerA) {Player.create(2)}
      let(:playerB) {Player.create(2)}
      let(:child){Player.reproduce_from(playerA, playerB, chr1, chr2)}

      it "returns a player with the same history_length as the parents" do
        child.should be_a Player
        child.history_length.should == 2
      end
      it "adds a chromosome that is the concatenation of the 2 chromosome parts" do
        child.chromosome.chromosome[0..chr1.size-1].should == chr1
        child.chromosome.chromosome[chr1.size..-1].should == chr2
      end
    end
  end
end
