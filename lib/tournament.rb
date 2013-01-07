require 'population'
require 'player'

# Implements the whole tournament. It has a population of players
# who play together in cycles. After each cycle, players are ranked and
# selected for reproduction, until a criterion for the population is reached.
class Tournament

  DEFAULT_NUM_PLAYERS = 20
  DEFAULT_HISTORY_LENGTH = 3
  DEFAULT_ROUND_LENGTH = 64
  DEFAULT_MAX_GENERATIONS = 200000

  MUTATION_ERROR_RATE = 0.1

  REWARD = 3
  TEMPTATION = 5
  SUCKER = 0
  PUNISHMENT = 1

  def initialize(observer, options = {})
    @observer = observer
    @round_length = options[:round_length] || DEFAULT_ROUND_LENGTH
    @population = Population.new(options[:num_players] || DEFAULT_NUM_PLAYERS,
                                 options[:history_length] || DEFAULT_HISTORY_LENGTH)
    @max_generations = options[:max_generations] || DEFAULT_MAX_GENERATIONS
    @num_generations = 0
  end

  def evolve
    while true
      play_one_cycle
      @observer.notify_state(@population, @num_generations)
      if criterion_reached
        break
      else
        reproduce(@population.select_fittest)
      end
    end
    @observer.notify_end(@population, @num_generations)
  end

  # In one cycle, each player plays one Round with every other player: with
  # a certain probability that depends on the distance between 2 players.
  def play_one_cycle
    couples = select_players_for_round
    couples.each do |couple|
      play_round(couple.first, couple.last)
    end
  end

  def play_round(player1, player2)
    @round_length.times { player1.play_with(player2) }
  end

  # Select players for reproduction based on score ranking.
  # From the selected players, choose 2 based on distance to combine their genes.
  # Create 2 new players that replace their parents.
  def reproduce(fittest)
    next_generation = []
    fittest.each do |player|
      mate = player.get_partner_from(fittest)
      if mate.nil?
        break unless add_child_to(next_generation, player.mutated_clone)
      else
        child1, child2 = player.cross_with(mate)
        break unless add_child_to(next_generation, child1.mutate!)
        break unless add_child_to(next_generation, child2.mutate!)
      end
    end
    @population.replace_players_with(next_generation)
    @num_generations += 1
  end

  # Creates an array of couples (each an array with 2 players). For each player,
  # a partner is selected with a probability based on the distance between the
  # players.
  # A player might play with the same partner more than once.
  def select_players_for_round
    couples = []
    @population.each do |player|
      (@population.size-1).times do
        couples << [player, player.get_partner_from(@population.players)]
      end
    end
    couples
  end

  def criterion_reached
     @num_generations >= @max_generations
  end

  private

  def add_child_to(next_generation, child)
    if @population > next_generation
      next_generation << child
      true
    else
      false
    end
  end

end