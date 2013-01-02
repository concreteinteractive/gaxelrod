class Action

  class << self

    def cooperative
      Action.new(true)
    end

    def treacherous
      Action.new(false)
    end

    def random_action
      rand(2) == 1 ? Action.cooperative : Action.treacherous
    end
  end

  def cooperative?
    @cooperative
  end

  def treacherous?
    not cooperative?
  end

  def ==(other)
    return false if self.class != other.class
    self.cooperative? == other.cooperative?
  end

  private
  def initialize(be_cooperative = true)
    @cooperative = be_cooperative
  end
end