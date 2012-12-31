require 'singleton'

# Defines the lattice as a normal class (not as a singleton), for unit testing.
class Lattice

  def initialize
    @players = {}
  end

  def add(player)
    element = Element.new(player)
    @players[element.id] = element
  end

  def add_between(child, player1, player2)

  end

  def remove(player)
    @players.each do |element|
      element.distances.reject! { |el| el.id == element.id }
    end
  end

  def distances_between(player, candidates)
    distances = []
    candidates.each_index do |i|
      distances << distance_between(player, candidates[i])
    end
    distances
  end

  def distance_between(player1, player2)
    p1 = @players[player1.id]
    p1.distances[player2.id]
  end

end

# Makes Lattice a singleton, for actual use in the rest of the application.
class UniqLattice < Lattice
  include Singleton
end

class element

  attr_accessor :player, :distances

  def initialize(player, distances = {})
    @player = player
    @distances = distances
  end

  def id
    @player.id
  end

end