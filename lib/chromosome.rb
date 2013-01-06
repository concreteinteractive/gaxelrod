require 'action'

class Chromosome

  attr_accessor :chromosome

  def initialize(history_length)
    @chromosome = []
    @history_length = history_length
  end

  class << self
    def create_randomly(history_length)
      chr = Chromosome.new(history_length)
      chr.fill_chromosome_randomly
      chr
    end

    def create_from(history_length, first_part, second_part)
      chr = Chromosome.new(history_length)
      chr.chromosome = first_part + second_part
      chr
    end
  end

  def get_next_move(history1, history2)
    if histories_lengths_valid(history1, history2)
      combined_history = combine(history1, history2)
      @chromosome[ combined_history.to_i(2) ]
    else
      get_prehistoric_action(history1, history2)
    end
  end

  def split_at(cross_point)
    return @chromosome[0..cross_point], @chromosome[cross_point+1..-1]
  end

  def []=(index, action)
    raise TypeError("Can assign only an Action.") unless action.class == Action
    @chromosome[index] = action
  end

  def [](index_or_range, to=nil)
    return @chromosome[index_or_range, to] if to
    return @chromosome[index_or_range]
  end

  def size
    @chromosome.size
  end

  def fill_chromosome_randomly
    (2**(@history_length*2)).times do
      @chromosome << Action.random_action
    end
    # add prehistoric action:
    @history_length.times { @chromosome << Action.random_action }
  end

  def to_s
    @chromosome.map{|a| a.to_s}.join
  end

  private

  def histories_lengths_valid(history1, history2)
    history1.size >= @history_length && history1.size == history2.size
  end

  # Combine the @history_length latest entries of both histories and
  # convert this to a binary string.
  def combine(history1, history2)
    combined_and_converted = ''
    (history1.size - @history_length..history1.size-1).each do |i|
      combined_and_converted += history1[i].cooperative? ? '1' : '0'
      combined_and_converted += history2[i].cooperative? ? '1' : '0'
    end
    combined_and_converted
  end

  # Looks up prehistoric actions from the tail of the
  # chromosome array:
  def get_prehistoric_action(history1, history2)
    shorter_size = history1.size < history2.size ? history1.size : history2.size
    shorter_size = @history_length if shorter_size > @history_length
    index = shorter_size+1
    @chromosome[-index]
  end
end