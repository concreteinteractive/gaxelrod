class Generation < ActiveRecord::Base
  attr_accessible :number, :score, :consumed

  has_many :agents, dependent: :destroy

  class << self
    def consume_next
      next_generation = first_unconsumed
      return nil if next_generation.nil?
      next_generation.update_attribute(:consumed, true)
      next_generation
    end

    def first_unconsumed
      Generation.where(consumed: false).order(:number).limit(1).first
    end

  end

end
