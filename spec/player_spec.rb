require "rspec"
require "lattice"
require "selector"
require "player"
require "chromosome"

describe "Player" do
  context "class methods" do
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
        player.chromosome.size.should > 0
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

  context "instance methods" do
    let(:player) {Player.create(2)}

    describe "get_partner_from" do

      before do
        @candidates = []
        4.times { @candidates << Player.create(2) }
        UniqLattice.instance.stub(:distances_between).and_return([3,10,8,1])
        Selector.stub(:pick_small_one).and_return(3)
      end

      it "returns an player from the candidates array" do
        player.get_partner_from(@candidates).should == @candidates[3]
      end
    end

    describe "play_with" do

      let(:partner) {Player.create(2)}

      before do
        Player.any_instance.stub(:decide).and_return(Action.cooperative)
      end

      it "updates the player's history with own action" do
        expect {
          player.play_with(partner)
        }.to change {player.history.size}.by(1)
      end
      it "increments the player's score" do
        expect {
          player.play_with(partner)
        }.to change {player.score}
      end
      it "updates the partner's history with his action" do
        expect {
          player.play_with(partner)
        }.to change {partner.history.size}.by(1)
      end
      it "increments the player's score" do
        expect {
          player.play_with(partner)
        }.to change {partner.score}
      end
    end

    describe "cross_with" do

      before do
        @crosspoint = 8
        @player1 = Player.create(2)
        @player2 = Player.create(2)
        Player.any_instance.stub(:rand).and_return(@crosspoint)
      end

      it "creates 2 new players whose chromosomes are a cross-over mix of the parents" do
        child1, child2 = @player1.cross_with(@player2)
        child1.chromosome[0..@crosspoint-1].should == @player1.chromosome[0..@crosspoint-1]
        child1.chromosome[@crosspoint..-1].should == @player2.chromosome[@crosspoint..-1]
        child2.chromosome[0..@crosspoint-1].should == @player2.chromosome[0..@crosspoint-1]
        child2.chromosome[@crosspoint..-1].should == @player1.chromosome[@crosspoint..-1]
      end
    end
  end
end
