class Agent < ActiveRecord::Base
  attr_accessible :chromosome, :generation_id, :history, :number, :score, :x, :y

  belongs_to :generation

end
