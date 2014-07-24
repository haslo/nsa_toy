class SearchablePeople < ActiveRecord::Base

  scope :search_with_index,    ->(query) { where("to_tsvector('english', document) @@ plainto_tsquery('english', ?)", query) }
  scope :search_with_trigrams, ->(query) { where("document % ?", query) }

  belongs_to :person, foreign_key: :id

end
