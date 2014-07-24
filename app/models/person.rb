class Person < ActiveRecord::Base

  scope :search_with_like,            ->(query) { where("name like '%#{query}%'") }
  scope :search_with_paragraph_like,  ->(query) { joins(:paragraphs).merge(Paragraph.search_with_like(query)) }

  scope :search_with_index,           ->(query) { where("to_tsvector('english', name) @@ plainto_tsquery('english', ?)", query) }
  scope :search_with_paragraph_index, ->(query) { joins(:paragraphs).merge(Paragraph.search_with_index(query)) }

  scope :search_with_combined_like,   ->(query) { where("id in (#{search_with_like(query).select('people.id').to_sql}) or id in (#{search_with_paragraph_like(query).select('people.id').to_sql})") }
  scope :search_with_combined_index,  ->(query) { where("id in (#{search_with_index(query).select('people.id').to_sql}) or id in (#{search_with_paragraph_index(query).select('people.id').to_sql})") }

  scope :search_with_view,            ->(query) { joins(:searchable_people).merge(SearchablePeople.search_with_index(query)) }
  scope :search_with_trigrams,        ->(query) { where("name % ?", query) }
  scope :search_with_view_trigrams,   ->(query) { joins(:searchable_people).merge(SearchablePeople.search_with_trigrams(query)) }

  scope :ordered_by_levenshtein,      ->(query) { order("levenshtein(name, '#{query}') asc") }

  has_many :paragraphs
  has_one :searchable_people, foreign_key: :id

  def self.search(query)
    search_with_like(query)#.ordered_by_levenshtein(query)
  end

end
