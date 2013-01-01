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
        players.class.should == Hash
        players[@player.id].class.should == Element
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

    describe "private methods" do
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
          (scaled.first / scaled.last.to_f).should == @vector.first / @vector.last.to_f
          orig_length = @lattice.calculate_distance([0,0], @vector)
          scaled_length = @lattice.calculate_distance([0,0], scaled)
          orig_length.should >= scaled_length
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