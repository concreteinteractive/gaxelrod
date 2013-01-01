require 'active_support/ordered_hash'

module Selector

  # Returns an index from the array probabilities using roulette wheel selection
  # (aka stochastic sampling with replacement), i.e. the index is selected based
  # on the size of the entries in this probabilities array: the larger an entry
  # is, the higher the probability it is selected.
  def self.pick_big_one(probabilities)
    # Calculate the cumulative probabilities; we're using a SortedSet and adding
    # cumulative i.e. constantly growing, probabilities, so the order of the initial
    # probabilities array is preserved.
    cumulative_probs = probabilities.inject(SortedSet.new([0])) do |result, prob|
      result << result.max + prob  # max should be fast, since the set is ordered
      result
    end
    r = rand * cumulative_probs.max
    # again, select, last, and find_index should be fast, since the set is ordered:
    selected_value = cumulative_probs.select{|value| value >= r}.last
    cumulative_probs.find_index(selected_value)
  end

  # Does the same as pick_big_one, but with "inversed" probabilities, so the larger
  # the probability is, the less likely its index will be selected.
  def self.pick_small_one(probabilities)
    self.pick_big_one( inverse(probabilities) )
  end

  private

  # Calculate the inverse of each probability in probabilities,
  # then normalise them so they sum up to 1 again.
  def self.inverse(probabilities)
    sum = 0
    inversed = probabilities.map do |prob|
      inv = 1/prob
      sum += inv
      inv
    end
    inversed.map { |prob| prob/sum }
  end
end