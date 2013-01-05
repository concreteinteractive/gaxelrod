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

  def add_between(child, point1, point2)
    child.x, child.y = random_point_between(point1, point2)
    add(child)
  end

  def add_near(child, player)
    child.x, child.y = random_point_near(player)
    add(child)
  end

  # Remove this player from the players list (hash) and
  # all references to this player from the other players'
  # distances hashes.
  def remove(player, remove_references = false)
    if remove_references
      @players.each_value do |element|
        element.distances.reject! { |key| key == player.id }
      end
    end
    @players.delete(player.id)
  end

  def calculate_distances
    #TODO calculates twice as many distances as necessary!
    @players.each_value do |element1|
      @players.each_value do |element2|
        if element1 != element2
          element1.distances[element2.id] = calculate_distance(element1.point, element2.point)
        end
      end
    end
  end

  def calculate_distance(point1, point2)
    a = (point2.first - point1.first)**2
    b = (point2.last - point1.last)**2
    Math.sqrt(a+b)
  end

  def distances_between(player, candidates)
    candidates.map do |candidate|
      distance_between(player, candidate)
    end
  end

  def distance_between(player1, player2)
    p1 = @players[player1.id]
    p1.distances[player2.id]
  end

  private

  # rp = point1 + (point2-point1)/2 + randomly_scale( rotate90( (point2-point1)/2 )
  def random_point_between(point1, point2)
    half_way = [point2.first - point1.first, point2.last - point1.last]
    half_way = [half_way.first/2.0, half_way.last/2.0]
    center = [point1.first + half_way.first, point1.last + half_way.last]
    random_part = rand_scale( rotate90(half_way) )
    [center.first + random_part.first, center.last + random_part.last]
  end

  # Return a point in a circle with center player.point
  # and radius |player.point, nearest_other_point|.
  def random_point_near(player)
    raise Exception("Player has no neighbors") if @players[player.id].distances.empty?
    max_radius = @players[player.id].distances.values.sort.first
    # directly transforming random radius and angle to polar coords
    # distorts the sampling; need to correct (see uniformly sampling a disk).
    radius = Math.sqrt(max_radius * rand)
    angle = 2 * Math::PI * rand
    dx = Math.cos(angle)*radius
    dy = Math.sin(angle)*radius
    [player.x + dx, player.y + dy]
  end

  def rotate90(p)
    x = p.first
    y = p.last
    [-y, x]
  end

  def rand_scale(p)
    x = p.first
    y = p.last
    r = rand
    [r*x, r*y]
  end
end

# Makes Lattice a singleton, for actual use in the rest of the application.
class UniqLattice < Lattice
  include Singleton
end

class Element

  attr_accessor :player, :distances

  def initialize(player, distances = {})
    @player = player
    @distances = distances
  end

  def id
    @player.id
  end

  def point
    [@player.x, @player.y]
  end

end