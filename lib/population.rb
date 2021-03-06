class Population

  extend Forwardable
  def_delegators :@players, :[], :each_index, :each, :size, :sort_by

  attr_reader :history_length
  attr_accessor :players

  def initialize(num_players, history_length)
    @history_length = history_length
    @players = []
    num_players.times {@players << Player.create(history_length)}
    UniqLattice.instance.calculate_distances
  end

  def replace_players_with(new_players)
    #@players.each { |p| UniqLattice.instance.remove(p) }
    UniqLattice.instance.keep_only(new_players)
    @players = new_players
    UniqLattice.instance.calculate_distances
  end

  # Select players with a probability based on their score ranking
  # (roulette wheel selection, aka stochastic sampling with replacement).
  def select_fittest
    fittest = []
    self.size.times do
      selected_index = Selector.pick_big_one(scores)
      fittest << @players[selected_index]
    end
    fittest
  end

  def >(array)
    @players.size > array.size
  end

  def total_score
    @players.inject(0) do |sum, player|
      sum += player.score
      sum
    end
  end

  private

  def scores
    @players.map{ |player| player.score }
  end

end