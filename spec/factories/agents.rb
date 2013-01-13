# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :agent do
    number 1
    x 1.5
    y 1.5
    chromosome "MyString"
    score 1.5
    generation 1
    history "MyString"
  end
end
