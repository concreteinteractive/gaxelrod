require "rspec"
require "selector"

describe "Selector" do

  before do
    @probabilities = [3, 10, 2]
  end

  describe "pick_big_one" do

    context "rand returns a medium value" do
      before do
        Selector.stub(:rand).and_return(0.5)
      end
      it "returns the index of a big entry of the probabilities array parameter" do
        # probabilities is [3, 10, 2] and the cumulative_prob hash is {3=>0, 13=>1, 15=>2}.
        # Since rand returns 0.5, r will be 7.5, so the first entry of cumulative_probs will be rejected.
        # From the remaining entries, the first one will be selected: 13=>1.
        Selector.pick_big_one(@probabilities).should == 1
      end
      it "returns the index of a big entry of the probabilities array parameter" do
        # probabilities is [0.2, 0,7, 0.1] and the cumulative_prob hash is {0.2=>0, 0.9=>1, 1=>2}.
        # Since rand returns 0.5, r will be 0.5, so the first entry of cumulative_probs will be rejected.
        # From the remaining entries, the first one will be selected: 0.9=>1.
        Selector.pick_big_one([0.2, 0.7, 0.1]).should == 1
      end
    end
    context "rand returns 0" do
      before do
        Selector.stub(:rand).and_return(0)
      end
      it "returns the index of the first entry of the probabilities array parameter" do
        # probabilities is [3, 10, 2] and the cumulative_prob hash is {3=>0, 13=>1, 15=>2}.
        # Since rand returns 0, r will be 0, so no entry of cumulative_probs will be rejected.
        # So from cumulative_prob hash, the first entry will be selected: 3=>0.
        Selector.pick_big_one(@probabilities).should == 0
      end
    end
    context "rand returns 1" do
      before do
        Selector.stub(:rand).and_return(1)
      end
      it "returns the index of the last entry of the probabilities array parameter" do
        # probabilities is [3, 10, 2] and the cumulative_prob hash is {3=>0, 13=>1, 15=>2}.
        # Since rand returns 1, r will be 15, so only the last entry of cumulative_probs will not be rejected.
        # Which is: 15=>2.
        Selector.pick_big_one(@probabilities).should == 2
      end
    end
  end

  describe "pick_small_one" do

    context "rand returns a medium value" do
      before do
        Selector.stub(:rand).and_return(0.5)
      end
      it "returns the index of a small entry of the probabilities array parameter" do
        Selector.pick_small_one(@probabilities).should == 2
      end
    end
    context "rand returns 0" do
      before do
        Selector.stub(:rand).and_return(0)
      end
      it "returns the index of the first entry of the probabilities array parameter" do
        Selector.pick_small_one(@probabilities).should == 0
      end
    end
    context "rand returns 1" do
      before do
        Selector.stub(:rand).and_return(1)
      end
      it "returns the index of the last entry of the probabilities array parameter" do
        Selector.pick_small_one(@probabilities).should == 2
      end
    end
  end

  describe "inverse" do
    it "makes large entries small and small entries big, preserving the proportions among the entries" do
      # probabilities is [2,4,2]
      # so un-normalized inversed is [1/2, 1/4, 1/2]
      # normalized is each entry divided by 5/4 [.4, .2, .4]
      inversed = Selector.send(:inverse, [2,4,2])
      inversed.should == [0.4, 0.2, 0.4]
    end
  end

  describe "yes_with_probability" do

    context "probability is 0" do
      it "returns almost never true" do
        Selector.stub(:rand).and_return(1.0e-20,0.5,1-1.0e-20)
        3.times {Selector.yes_with_probability(0).should be_false}
      end
    end
    context "probability is 1" do
      it "returns almost always true" do
        Selector.stub(:rand).and_return(1.0e-20,0.5,1-1.0e-20)
        3.times {Selector.yes_with_probability(1).should be_true}
      end
    end
    context "probability is 0.5" do
      it "returns true if the random number is greater than 0.5" do
        Selector.stub(:rand).and_return(0.51)
        Selector.yes_with_probability(0.5).should be_true
      end
      it "returns false if the random number is smaller than 0.5" do
        Selector.stub(:rand).and_return(0.49)
        Selector.yes_with_probability(0.5).should be_false
      end
    end
  end

end
