class Paragraph < ActiveRecord::Base

  scope :search_with_like,  ->(query) { where("text like '%#{query}%'") }
  scope :search_with_index, ->(query) { where("to_tsvector('english', text) @@ plainto_tsquery('english', ?)", query) }

  belongs_to :person

end
