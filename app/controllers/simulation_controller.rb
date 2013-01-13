class SimulationController < ApplicationController

  def start
    reset_db
    SimulationWorker.perform_async(options)
    render json: "started"
  end

  def next
  end

  private

  def options
    ops = {}
    ops[:round_length]    = params[:round_length] || 64
    ops[:num_players]     = params[:num_players] || 10
    ops[:history_length]  = params[:history_length] || 3
    ops[:max_generations] = params[:max_generations] || 11
    ops
  end

  def reset_db
    Agent.all.each{|p| p.destroy }
  end


end