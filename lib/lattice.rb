require 'singleton'

# Defines the lattice as a normal class (not as a singleton), for unit testing.
class Lattice

  def distances_between(player, candidates)
    distances = []
    candidates.each_index do |i|
      distances << distance_between(player, candidates[i])
    end
    distances
  end

end

# Makes Lattice a singleton, for actual use in the rest of the application.
class UniqLattice < Lattice
  include Singleton

end