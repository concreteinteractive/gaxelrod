require 'singleton'

# Defines the lattice as a normal class (not as a singleton), for unit testing.
class Lattice

  MIN_DISTANCE = 0.001

  attr_reader :players

  def initialize
    @players = {}
  end

  def add(player)
    element = Element.new(player)
    @players[element.id] = element
  end

  def add_around(child, player1, player2)
    player = rand < 0.5 ? player1 : player2
    child.x, child.y = random_point_near(player)
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

  def keep_only(new_players)
    new_player_ids = new_players.map{|player| player.id }
    @players.keep_if { |player_id, element| new_player_ids.include? player_id }
  end

  def calculate_distances(reset = true)
    #TODO calculates twice as many distances as necessary!
    @players.each_value do |element1|
      element1.distances = {} if reset
      @players.each_value do |element2|
        if element1 != element2
          element1.distances[element2.id] = calculate_distance(element1.point, element2.point)
        end
      end
    end
  end

  def calculate_distance(point1, point2)
    dx = (point2.first - point1.first)**2
    dy = (point2.last - point1.last)**2
    Math.sqrt(dx+dy)
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

  # Returns a point that somewhere within a circle with center (p1-p2)/2
  # and radius p1-p2.
  # If this circle was smaller, the points will lump together over time, so that all
  # player will converge on a single point.
  # @deprecated
  def random_point_around(point1, point2)
    half_way = [point2.first - point1.first, point2.last - point1.last]
    half_way = [half_way.first/2.0, half_way.last/2.0]
    center = [point1.first + half_way.first, point1.last + half_way.last]

    random_part = rand_scale( rotate90(half_way) )
    [center.first + random_part.first, center.last + random_part.last]
  end

  # Return a point in a circle with center player.point
  # and radius 2 * |player.point, nearest_other_point|.
  # The radius needs to be twice the distance from the point to its
  # nearest neighbor, otherwise the players will get closer and closer,
  # circling in all on the same point!
  def random_point_near(player)
    raise "Player has no neighbors" if @players[player.id].distances.empty?
    max_radius = @players[player.id].distances.values.sort.first
    # directly transforming random radius and angle to polar coords
    # distorts the sampling; need to correct (see uniformly sampling a disk).
    radius = 2 * max_radius * Math.sqrt(rand)
    angle = 2 * Math::PI * rand
    dx = Math.cos(angle)*radius
    dy = Math.sin(angle)*radius
    dx = rand if dx < MIN_DISTANCE
    dy = rand if dy < MIN_DISTANCE
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