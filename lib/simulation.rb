lib = File.dirname(File.absolute_path(__FILE__))
Dir.glob(lib + './*.rb'){|file| require file}

#require_relative 'tournament'
#require_relative 'population'
#require_relative 'player'
#require_relative 'selector'
#require_relative 'lattice'
#require_relative 'chromosome'
#require_relative 'action'

module Simulation

  def self.notify_state(population, generation)
    puts "Generation nr #{generation}: Total score is #{population.total_score}"
  end

  def self.notify_end(population, generation)
    puts "Simulation done:"
    puts "Generation nr #{generation}: Total score is #{population.total_score}"
  end

end

module SimulationRunner

  def default_options
    options = {}
    options[:round_length] = 64
    options[:num_players]  = 20
    options[:history_length] = 3
    options[:max_generations] = 1000
  end

  def run
    tournament = Tournament.new(Simulation, default_options)
    tournament.evolve
  end
end