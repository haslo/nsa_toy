class Person < ActiveRecord::Base

  scope :search, ->(query) { where("name like '%#{query}%'") }

end
