class GenerationsController < ApplicationController

  def new

  end

  def start
    reset_db
    SimulationWorker.perform_async(options)
    render json: {msg: "started"}
  end

  def next
    render json: Generation.consume_next.as_json(
        only: [:number, :score],
        include: [agents: {only: [:number, :score, :chromosome, :x, :y]}]
    )
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
    Generation.all.each{|g| g.destroy }
  end


end