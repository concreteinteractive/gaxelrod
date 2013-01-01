require "active_support/ordered_hash"

module Selector

  # Returns an index from the array probabilities using roulette wheel selection
  # (aka stochastic sampling with replacement), i.e. the index is selected based
  # on the size of the entries in this probabilities array: the larger an entry,
  # the higher the probability it is selected.
  def self.pick_big_one(probabilities)
    # TODO this algorh doesn't work since associations to orig indinces are lost
    # when creating the sorted set for the cumulative probs!
    # Calculate the cumulative probabilities; we're using a SortedSet and adding
    # cumulative i.e. constantly growing, probabilities, so the order of the initial
    # probabilities array is preserved.
    cumulative_probs = ActiveSupport::OrderedHash.new
    probabilities.each_with_index do |prob, index|
      if index == 0
        cum_prob = 0
      else
        cum_prob = cumulative_probs.keys.last
      end
      cumulative_probs[cum_prob + prob] = index
    end

    puts cumulative_probs

    # last entry in the cum.probs hash contains sum of all probalilties
    r = rand * cumulative_probs.keys.last
    puts "cumprob.lastkey is #{cumulative_probs.keys.last}, r is #{r}"
    # again, select, last, and find_index should be fast, since the set is ordered:
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