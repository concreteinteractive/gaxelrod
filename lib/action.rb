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

  private
  def initialize(be_cooperative = true)
    @cooperative = be_cooperative
  end
end