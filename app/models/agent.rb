class Agent < ActiveRecord::Base
  attr_accessible :chromosome, :generation, :history, :number, :score, :x, :y
end
