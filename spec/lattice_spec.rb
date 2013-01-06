require "rspec"
require "lattice"
require "player"

describe "Lattice" do

  describe "public interface" do

    before do
      @lattice = Lattice.new
    end

    describe "add" do

      before do
        @player = Player.new(2)
      end
      it "adds an element to the players hash" do
        @lattice.add(@player)
        players = @lattice.instance_eval{ @players }
        players.should be_a Hash
        players[@player.id].should be_a Element
      end
      it "adds a second element to the players hash" do
        @lattice.add(@player)
        player2 = Player.new(2)
        @lattice.add(player2)
        players = @lattice.instance_eval{ @players }
        players.size.should == 2
        players[@player.id].id.should == @player.id
        players[player2.id].id.should == player2.id
      end
    end

    describe "remove" do
      before do
        @p1 = Player.new(2)
        @p3 = Player.new(2)
        @p2 = Player.new(2)
        @lattice.add(@p1)
        @lattice.add(@p2)
        @lattice.add(@p3)
        @lattice.calculate_distances
      end

      let(:players) { @lattice.instance_eval{@players} }

      it "removes a player from @players" do
        players.has_key?(@p2.id).should be_true
        @lattice.remove(@p2)
        players.has_key?(@p2.id).should be_false
      end
      it "removes all references to the removed player if called with parameter true" do
        @lattice.remove(@p2, true)
        players.each_value do |element|
          element.distances.has_key?(@p2.id).should be_false
        end
      end
    end

    describe "keep_only" do
      before do
        @p1 = Player.new(2)
        @p3 = Player.new(2)
        @p2 = Player.new(2)
        @lattice.add(@p1)
        @lattice.add(@p2)
        @lattice.add(@p3)
        @lattice.calculate_distances
      end

      it "removes all player-elements that are not in keep-array" do
        @lattice.keep_only([@p1, @p3])
        @lattice.players.values.map{|element| element.player }
                        .should == [@p1, @p3]
      end
      it "removes no player-elements if the keep-array includes all Lattice players" do
        @lattice.keep_only([@p1, @p3, @p2])
        @lattice.players.values.map{|element| element.player }
                .sort_by{|player| player.id}.should == [@p1, @p2, @p3].sort_by{|player| player.id}
      end
      it "removes all player-elements if the keep-array is empty" do
        @lattice.keep_only([])
        @lattice.players.empty?.should be_true
      end
    end

    describe "add_around" do

      before do
        @player1 = Player.new(2, 1, 2)
        @player2 = Player.new(2, 3, 2)
        @child = Player.new(2, -10, -10)
        @lattice.add(@player1)
        @lattice.add(@player2)
        @lattice.add(Player.new(2, 4, 2))
        @lattice.calculate_distances
      end

      it "adds a player" do
        expect {
          @lattice.add_around(@child, @player1, @player2)
        }.to change{@lattice.instance_eval{@players}.size}.by(1)
      end

      context "the first player is (randomly) selected" do
        before { Lattice.any_instance.stub(:rand).and_return(0.2) }
        it "adds a player in a circle around one of the 2 passed in players" do
          @lattice.add_around(@child, @player1, @player2)
          # (further testing of where the child.x and .y are: see specs for random_point_near)
          dist = @lattice.calculate_distance(@child.point, @player1.point)
          dist.should < 4 # twice the distance between player1 and its nearest neighbor, player2
        end
      end
      context "the second player is (randomly) selected" do
        before { Lattice.any_instance.stub(:rand).and_return(0.7) }
        it "adds a player in a circle around one of the 2 passed in players" do
          @lattice.add_around(@child, @player1, @player2)
          # (further testing of where the child.x and .y are: see specs for random_point_near)
          dist = @lattice.calculate_distance(@child.point, @player2.point)
          dist.should < 2 # twice the distance between player2 and its nearest neighbor (third player)
        end
      end

    end

    describe "add_near" do
      before do
        @child = Player.new(2, 0, 0)
        @player = Player.new(2, 2, 2)
        @lattice.add(@player)
        @lattice.add(Player.new(2, 4, 2))
        @lattice.add(Player.new(2, 4, 3))
        @lattice.calculate_distances
      end

      it "adds a player" do
        expect {
          @lattice.add_near(@child, @player)
        }.to change{@lattice.instance_eval{@players}.size}.by(1)
      end

      it "adds a player not farther than twice the distance to the player's nearest neighbor" do
        @lattice.add_near(@child, @player)
        dist = @lattice.calculate_distance(@child.point, @player.point)
        dist.should <= 4
      end
    end

    describe "distance calculation" do

      before do
        @lattice = Lattice.new
        @p1 = Player.new(2, 0, 0)
        @p2 = Player.new(2, 1, 0)
        @p3 = Player.new(2, 2, 0)
        @lattice.add(@p1)
        @lattice.add(@p2)
        @lattice.add(@p3)

        @lattice.calculate_distances
      end

      describe "calculate_distance" do
        it "returns the distance between 2 points" do
          d = @lattice.calculate_distance([6,5], [2,8])
          d.should == 5
        end
        it "returns 0 if the points are identical" do
          d = @lattice.calculate_distance([6,5], [6,5])
          d.should == 0
        end
        it "retuns the distance between 2 points when the are on the same axis" do
          d = @lattice.calculate_distance([6,5], [7,5])
          d.should == 1
        end
      end

      describe "calculate_distances" do
        it "calculates the distances between all the players" do
          players = @lattice.instance_eval{ @players }
          players[@p1.id].distances[@p1.id].should be_nil
          players[@p1.id].distances[@p2.id].should == 1
          players[@p1.id].distances[@p3.id].should == 2

          players[@p2.id].distances[@p2.id].should be_nil
          players[@p2.id].distances[@p1.id].should == 1
          players[@p2.id].distances[@p3.id].should == 1

          players[@p3.id].distances[@p3.id].should be_nil
          players[@p3.id].distances[@p1.id].should == 2
          players[@p3.id].distances[@p2.id].should == 1
        end
      end

      describe "distances_between" do
        it "returns an array with the distances between the player and all candidates" do
          distances = @lattice.distances_between(@p1, [@p2, @p3])
          distances.should == [1, 2]
        end
      end

      describe "distance_between" do
        it "returns the distance between 2 players" do
          @lattice.distance_between(@p1, @p2).should == 1
          @lattice.distance_between(@p1, @p3).should == 2
          @lattice.distance_between(@p2, @p3).should == 1
        end
      end
    end

    describe "private helper methods" do
      before do
        @vector = [3,4]
      end

      describe "rotate90" do
        it "rotates a vector by 90deg" do
          @lattice.send(:rotate90, @vector).should == [-4, 3]
          @lattice.send(:rotate90, [0,1]).should == [-1, 0]
          @lattice.send(:rotate90, [-1,-1]).should == [1, -1]
        end
      end

      describe "rand_scale" do
        it "scales a vector by a random number between 0 and 1" do
          scaled = @lattice.send(:rand_scale, @vector)
          (scaled.first / scaled.last.to_f).should be_within(0.001).of(@vector.first / @vector.last.to_f)
          orig_length = @lattice.calculate_distance([0,0], @vector)
          scaled_length = @lattice.calculate_distance([0,0], scaled)
          orig_length.should >= scaled_length
        end
      end

      describe "random_point_near" do
        before do
          Lattice.any_instance.stub(:rand).and_return(1, 0.25)
          @player = Player.new(2, 2, 2)
          @lattice.add(@player)
          @lattice.add(Player.new(2, 4, 2))
          @lattice.add(Player.new(2, 4, 3))
          @lattice.calculate_distances
        end
        it "returns a point not farther away from self than its nearest player" do
          point = @lattice.send(:random_point_near, @player)
          point.first.should be_within(0.0001).of(@player.x)
          point.last.should be_within(0.0001).of(@player.y + 4)
        end
      end
    end
  end

end

describe "Element" do

  before do
    @player = Player.new(2)
    @element = Element.new(@player)
  end

  describe "new" do
   it "assigns player and has a distances hash" do
     @element.instance_eval{@player}.should == @player
     @element.instance_eval{@distances}.should == {}
   end
  end
  describe "id" do
    it "returns the id of the player" do
      @element.id.should == @player.id
    end
  end
  describe "point" do
    it "returns an array with the players's x and y" do
      @element.point.should == [@player.x, @player.y]
    end
  end
end