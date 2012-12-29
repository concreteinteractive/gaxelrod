require 'singleton'

# Defines the lattice as a normal class (not as a singleton), for unit testing.
class Lattice

end

# Makes Lattice a singleton, for actual use in the rest of the application.
class UniqLattice < Lattice
  include Singleton

end