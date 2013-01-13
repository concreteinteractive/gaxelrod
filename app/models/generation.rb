class Generation < ActiveRecord::Base
  attr_accessible :number, :score, :consumed

  has_many :agents, dependent: :destroy

  class << self
    def consume_next
      next_generation = Generation.where(consumed: false).order(:number).limit(1).first
      return nil if next_generation.nil?
      next_generation.update_attribute(:consumed, true)
      next_generation
    end
  end

end
