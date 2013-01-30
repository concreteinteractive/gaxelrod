class SimulationWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :backtrace => true

  def perform(options)
    tournament = Tournament.new(self, options)
    tournament.evolve
  end

  def notify_state(population, generation)
    display(generation, population, 4)
    new_generation = Generation.create(number: generation,
                                       score: population.total_score,
                                       consumed: false)
    population.players.each{|p| add_player(new_generation, p) }
  end

  def notify_end(population, generation)
    info "Simulation done:"
    display(generation, population, population.size)
  end

  def display(generation, population, num_top_players)
    info "Generation nr #{generation}: Total score is #{population.total_score}"
    sorted_players = population.sort_by{|p| p.score }
    sorted_players[-num_top_players..-1].each do |p|
      info "Score: #{p.score}; #{p.chromosome}"
    end

  end

  def add_player(generation, player)
    generation.agents.create do |agent|
      agent.number = player.id
      agent.chromosome = player.chromosome.to_s
      agent.score = player.score
      agent.x = player.x
      agent.y = player.y
      agent.history = player.history.map{|action| action.to_s}.join
    end
  end

  def info(msg)
    logger.info msg
    #puts msg
  end

end