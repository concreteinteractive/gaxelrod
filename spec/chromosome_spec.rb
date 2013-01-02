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

  describe "class methods" do
    describe "create_randomly" do
      it "creates a Chromosome and fills it with random actions" do
        random_chr = Chromosome.create_randomly(2)
        random_chr.chromosome.size.should == 16
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
      @action0000 = @chromosome.chromosome[0]   #0 = 0000 binary
      @action1000 = @chromosome.chromosome[9]   #8 = 1000 binary
      @action1001 = @chromosome.chromosome[9]   #9 = 1001 binary
      @action1111 = @chromosome.chromosome[15]  #15= 1111 binary
    end

    it "returns the n-th entry from the chromosome, where n is binary number coded by the combined histories" do
      @chromosome.get_next_move(@history1, @history2).should == @action1000
      @chromosome.get_next_move([Action.treacherous, Action.treacherous],
                                [Action.treacherous, Action.treacherous]).should == @action0000
      @chromosome.get_next_move([Action.treacherous, Action.treacherous],
                                [Action.treacherous, Action.cooperative]).should == @action1001
      @chromosome.get_next_move([Action.cooperative, Action.cooperative],
                                [Action.cooperative, Action.cooperative]).should == @action1111
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
        combined = @chromosome.send(:combine, @history1, @history2)
        combined.should == "1000"
      end
    end
  end


end
