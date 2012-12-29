class Population

  attr_reader :history_length
  attr_accessor :players

  def initialize(num_players, history_length)
    @history_length = history_length
    @players = []
    num_players.times {@players << Player.create(history_length)}
    Lattice.instance.calculate_distances
  end

  def replace_players_with(new_players)
    players.each { |p| Lattice.instance.remove(p) }
    @players = new_players
    Lattice.instance.calculate_distances
  end

  def size
    @players.size
  end

  # Select players with a probability based on their score ranking
  # (roulette wheel selection, aka stochastic sampling with replacement).
  def select_fittest
    fittest = []
    self.size.times do
      selected_index = Selector.select(self.normalized_scores)
      fittest << @players[selected_index]
    end
    fittest
  end

  private

  def normalized_scores
    total = self.total_score
    @players.map{ |player| player.score/total }
  end

  def total_score
    @players.inject(0) do |total, player|
      total += player.score
      total.to_f
    end
  end

end