require "active_support/ordered_hash"

module Selector

  # Returns an index from the array probabilities using roulette wheel selection
  # (aka stochastic sampling with replacement), i.e. the index is selected based
  # on the size of the entries in this probabilities array: the larger an entry,
  # the higher the probability it is selected.
  # Probabilities array doesn't need to be actual probabilities (that sum up to 1).
  # It just needs to be a list of numbers (integers or e.g. real nr).
  def self.pick_big_one(probabilities)
    # Calculate the cumulative probabilities. Store them in a hash as
    # keys, and each value is the according index of the probabilities array:
    cumulative_probs = ActiveSupport::OrderedHash.new
    probabilities.each_with_index do |prob, index|
      cum_prob = index == 0 ? 0 : cumulative_probs.keys.last
      cumulative_probs[cum_prob + prob] = index
    end

    # last entry in the cum.probs hash contains sum of all probalilties
    r = rand * cumulative_probs.keys.last
    cumulative_probs.select!{|key| key >= r}
    cumulative_probs[cumulative_probs.keys.first]
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
      inv = 1.0/prob
      sum += inv
      inv
    end
    inversed.map { |prob| prob/sum }
  end
end