require 'lattice'
require 'selector'

class Player

  attr_reader :score, :history
  attr_accessor :chromosome, :x, :y

  REWARD = 3
  TEMPTATION = 5
  SUCKER = 0
  PUNISHMENT = 1

  # Creates a player with a random chromosome and a random location.
  def initialize
    @chromosome = []
    @history = []
    @score = 0
    @x = 0
    @y = 0
  end

  class << self

    def create(history_length)
      p = Player.new
      p.chromosome = Chromosome.new(history_length)
      p.x = rand
      p.y = rand
      Lattice.instance.add(p)
      p
    end

    def reproduce_from(player1, player2, chromosome_first_half, chromosome_second_half)
      p = Player.new
      p.x = (player1.x + player2.x) / 2
      p.y = (player1.y + player2.y) / 2
      lattice.instance.add(p)
      p.chromosome = Chromosome.create_from()
    end
  end

  def play_with(other_player)
    self_action =  self.decide(@history, other_player.history)
    other_action = other_player.decide(other_player.history, @history)
    self.update(self_action, other_action)
    other_player.update(other_action, self_action)
  end

  # Selects one player from players with a probability based on the distance
  # to the players.
  def get_mate_from(players)
    distances = []
    players.each_index {|i| distances << Lattice.instance.distance_between(self, players[i]) }
    selected_index = Selector.select(distances)
    players(selected_index)
  end

  def cross_with(partner)
    cross_point = rand(@chromosome.size)
    self_a, self_b       = self.split_at(cross_point)
    partner_a, partner_b = partner.split_at(cross_point)
    [Player.reproduce_from(self, partner, self_a, partner_b),
     Player.reproduce_from(self, partner, partner_a, self_b)]
  end

  def split_at(cross_point)
    @chromosome.split_at(cross_point)
  end

  private

  def decide(self_history, other_history)
    @chromosome.get_next_move(self_history, other_history)
  end

  def update(self_action, other_action)
    self.history << self_action
    count!(self_action, other_action)
  end

  def count!(self_action, other_action)
    if self_action.cooperative
      @score += REWARD if other_action.cooperative?
    else
      @score += other_action.cooperative? ? TEMPTATION : PUNISHMENT
    end
  end

end