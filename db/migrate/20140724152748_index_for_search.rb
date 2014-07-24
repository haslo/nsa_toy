class IndexForSearch < ActiveRecord::Migration
  def change

    execute("create index name_index on people using gin(to_tsvector('english', name))")
    execute("create index text_index on paragraphs using gin(to_tsvector('english', text))")

  end
end
