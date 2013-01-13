class SimulationWorker
  include Sidekiq::Worker

  def perform(options)
    tournament = Tournament.new(self, options)
    tournament.evolve
  end

  def notify_state(population, generation)
    display(generation, population, 4)
    population.players.each do |player|
      Agent.create do |agent|
        agent.number = player.id
        agent.generation = generation
        agent.chromosome = player.chromosome.to_s
        agent.score = player.score
        agent.x = player.x
        agent.y = player.y
        agent.history = player.history.map{|action| action.to_s}.join
        agent.consumed = false
      end
    end
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

  def info(msg)
    logger.info msg
    #puts msg
  end

end