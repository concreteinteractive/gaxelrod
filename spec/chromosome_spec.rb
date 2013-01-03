require "rspec"
require "action"
require "chromosome"

describe "Chromosome" do

  before do
    @chromosome = Chromosome.new(2)
    @history1 = [Action.cooperative, Action.cooperative, Action.treacherous]
    @history2 = [Action.cooperative, Action.treacherous, Action.treacherous]
  end
  describe "new" do
    it "has an empty chromosome array and the specified length" do
      @chromosome.chromosome.should == []
      @chromosome.instance_eval{@history_length}.should == 2
    end
  end
  describe "size" do
    it "returns the length of the @chromosome array" do
      chr = Chromosome.create_randomly(2)
      chr.size.should == chr.chromosome.size
    end
    it "returns 0 for an new chromosome" do
      @chromosome.size.should == 0
    end
  end

  describe "class methods" do
    describe "create_randomly" do
      it "creates a Chromosome and fills it with random actions" do
        random_chr = Chromosome.create_randomly(2)
        random_chr.size.should == 16
        random_chr.chromosome.each {|action| action.class.should == Action}
      end
      it "creates a Chromosome whose @chromosome is a concatenation of 2 partial chromosomes" do
        first_part = [Action.cooperative, Action.treacherous]
        second_part = [Action.cooperative, Action.cooperative]
        combined_chr = Chromosome.create_from(2, first_part, second_part)
        combined_chr.chromosome.map{|a| a.cooperative?}.should == [true, false, true, true]
      end
    end
  end

  describe "get_next_move" do

    before do
      @chromosome = Chromosome.create_randomly(2)
      @action0000 = @chromosome.chromosome[0]   #0 = 0000 binary
      @action1000 = @chromosome.chromosome[8]   #8 = 1000 binary
      @action1001 = @chromosome.chromosome[9]   #9 = 1001 binary
      @action1111 = @chromosome.chromosome[15]  #15= 1111 binary

      #MockAction = mock(Action)
      Action.stub(:random_action).and_return(Action.cooperative)
    end

    it "returns the n-th entry from the chromosome, where n is binary number coded by the combined histories" do
      @chromosome.get_next_move(@history1, @history2).should == @action1000
      @chromosome.get_next_move([Action.treacherous, Action.treacherous],
                                [Action.treacherous, Action.treacherous]).should == @action0000
      @chromosome.get_next_move([Action.cooperative, Action.treacherous],
                                [Action.treacherous, Action.cooperative]).should == @action1001
      @chromosome.get_next_move([Action.cooperative, Action.cooperative],
                                [Action.cooperative, Action.cooperative]).should == @action1111
    end
    it "returns a random_action if any of the histories is not valid" do
      @chromosome.get_next_move(@history1, @history2[0..1]).cooperative?.should be_true
    end
  end

  describe "split_at" do

    let(:expected_part1) {@chromosome.chromosome[0..@crosspoint]}
    let(:expected_part2) {@chromosome.chromosome[@crosspoint+1..-1]}

    before do
      @crosspoint = 5
      @chromosome = Chromosome.create_randomly(2)
    end

    it "splits the chromosome at the position specified by cross_point" do
      @chromosome.split_at(@crosspoint).should == [expected_part1, expected_part2]
    end
    it "returns an array with only the first action and the rest of chromosome array if the crosspoint is 0" do
      @chromosome.split_at(0).should == [[@chromosome.chromosome.first],
                                         @chromosome.chromosome[1..-1]]
    end
    it "returns an array with the entire chromosome exept the last action and an array with the last action" do
      @crosspoint = @chromosome.size-1
      @chromosome.split_at(@crosspoint).should == [expected_part1, expected_part2]
    end
  end

  describe "[]" do

    let(:expected_action) {@chromosome.chromosome[@position]}

    before do
      @position = 5
    end

    it "returns the action at the specified position" do
      @chromosome[@position].should == expected_action
      @chromosome[@position = 1].should == expected_action
      @chromosome[@position = 11].should == expected_action
      @chromosome[@position = 7].should == expected_action
      @chromosome[@position = 0].should == expected_action
      @chromosome[@position = @chromosome.size-1].should == expected_action
    end
  end

  describe "[]=" do
    it "assigns the specified action at the specified position" do
      action = Action.cooperative
      last = @chromosome.size - 1
      @chromosome[0] = action
      @chromosome[0].should == action

      @chromosome[last] = action
      @chromosome[last].should == action

      position = last/2
      @chromosome[position] = action
      @chromosome[position].should == action
    end
    it "raises an exception if one tries to assign anything else than an Action" do
      lambda{@chromosome[0] = "Not an action"}.should raise_error
    end
  end

  describe "private methods" do
    describe "histories_lengths_valid" do
      it "returns true if both histories have the same length and are longer than @history_length" do
        @chromosome.send(:histories_lengths_valid, @history1, @history2).should be_true
      end
      it "returns true if both histories have the same length, equal to @history_length" do
        @chromosome.send(:histories_lengths_valid, @history1[0..1], @history2[0..1]).should be_true
      end
      it "returns false if both histories have the same length but are shorter than @history_length" do
        @chromosome.send(:histories_lengths_valid, @history1[0,1], @history2[0,1]).should be_false
      end
      it "returns false if the histories don't have the same length" do
        @chromosome.send(:histories_lengths_valid, @history1, @history2[0..1]).should be_false
      end
    end

    describe "combine" do
      it "combines 2 histories and converts them to a 0-1-string" do
        # history1 is CCT which translates to 110
        # history2 is CTT which translates to 100
        # only the latest 2 are considered, since history_length is 2 here:
        @chromosome.send(:combine, @history1, @history2).should == "1000"
        @chromosome.send(:combine, @history2, @history1).should == "0100"
      end
    end
  end


end
