require "rspec"
require "action"

describe "Action" do
  describe "Class methods" do
    describe "Action.cooperative" do
      it "creates a cooperative action" do
        action = Action.cooperative
        action.should be_an Action
        action.instance_eval{@cooperative}.should be_true
      end
    end
    describe "Action.treacherous" do
      it "creates a treacherous action" do
        action = Action.treacherous
        action.should be_an Action
        action.instance_eval{@cooperative}.should be_false
      end
    end
    describe "Action.random_action" do
      it "returns an action" do
        Action.random_action.should be_an Action
      end
    end
  end

  describe "cooperative?" do
    it "returns true if the action is cooperative" do
      Action.cooperative.cooperative?.should be_true
    end
    it "returns false if the action is treacherouse" do
      Action.treacherous.cooperative?.should be_false
    end
  end
  describe "treacherous" do
    it "returns true if the action is treacherous" do
      Action.treacherous.treacherous?.should be_true
    end
    it "returns false if the action is cooperative" do
      Action.cooperative.treacherous?.should be_false
    end
  end

  describe "==" do

    let(:cooper)   {Action.cooperative}
    let(:treacher) {Action.treacherous}

    it "returns true if self is cooperative and the other is as well" do
      (cooper == Action.cooperative).should be_true
    end
    it "returns false if self is cooperative and the other is not" do
      (cooper == Action.treacherous).should be_false
    end
    it "returns true if self is treacherous and the other is as well" do
      (treacher == Action.treacherous).should be_true
    end
    it "returns false if self is treacherous and the other is not" do
      (treacher == Action.cooperative).should be_false
    end
    it "returns false if the other object is not an Action" do
      (cooper == "n'importe quoi").should be_false
      (treacher == "n'importe quoi").should be_false
    end
  end

end
