require 'chromosome'
require 'lattice'
require 'selector'
require 'tournament'

class Player

  attr_reader :id, :score, :history, :history_length
  attr_accessor :chromosome, :x, :y

  # 'global' counter to generate sequential ids for the Player instances:
  @@current_player_id = 0

  # Creates a player with a random chromosome and a random location.
  def initialize(history_length, x = nil, y = nil)
    @id = Player.next_id
    @chromosome = nil
    @history = []
    @score = 0
    @history_length = history_length
    @x = x ? x : 0
    @y = y ? y : 0
  end

  class << self

    def create(history_length)
      p = Player.new(history_length)
      p.chromosome = Chromosome.create_randomly(history_length)
      p.x = rand
      p.y = rand
      UniqLattice.instance.add(p)
      p
    end

    def reproduce_from(player1, player2, chromosome_first_part, chromosome_second_part)
      child = Player.new(player1.history_length)
      child.chromosome = Chromosome.create_from(child.history_length, chromosome_first_part, chromosome_second_part)
      UniqLattice.instance.add_around(child, player1, player2)
      child
    end

    def clone_with_errors(player, num_mutations)
      child = Player.new(player.history_length)
      child.chromosome = Chromosome.create_from(child.history_length, player.chromosome[0..-1], [])
      UniqLattice.instance.add_near(child, player)
      num_mutations.times {child.mutate!}
      child
    end

    def next_id
      @@current_player_id += 1
      @@current_player_id
    end
  end

  # Selects a partner from the candidates array with a probability
  # based on the distance to this player: the nearer, the more probable.
  # The partner cannot be self.
  def get_partner_from(players)
    candidates = players.reject{|player| player == self}
    return nil if candidates.empty?
    distances = UniqLattice.instance.distances_between(self, candidates)
    selected_index = Selector.pick_small_one(distances)
    candidates[selected_index]
  end

  def play_with(other_player)
    self_action =  self.decide(@history, other_player.history)
    other_action = other_player.decide(other_player.history, @history)
    self.update(self_action, other_action)
    other_player.update(other_action, self_action)
  end

  def cross_with(partner)
    cross_point = rand(@chromosome.size)
    self_a, self_b       = self.split_at(cross_point)
    partner_a, partner_b = partner.split_at(cross_point)
    [Player.reproduce_from(self, partner, self_a, partner_b),
     Player.reproduce_from(self, partner, partner_a, self_b)]
  end

  def mutated_clone
    Player.clone_with_errors(self, mutation_error_rate)
  end

  def mutate!
    mutation_point = rand(@chromosome.size)
    @chromosome[mutation_point] = Action.random_action
    self
  end

  def point
    [@x, @y]
  end

  # Returns next action, based on own and partner's history.
  def decide(self_history, other_history)
    @chromosome.get_next_move(self_history, other_history)
  end

  def update(self_action, other_action)
    self.history << self_action
    count!(self_action, other_action)
  end

  def split_at(cross_point)
    @chromosome.split_at(cross_point)
  end

  def to_s
    "player#{@id}"
  end


  def mutation_error_rate
    (@chromosome.size * Tournament::MUTATION_ERROR_RATE).round
  end

  private

  def count!(self_action, other_action)
    if self_action.cooperative?
      @score += other_action.cooperative? ? Tournament::REWARD : Tournament::SUCKER
    else
      @score += other_action.cooperative? ? Tournament::TEMPTATION : Tournament::PUNISHMENT
    end
  end

end