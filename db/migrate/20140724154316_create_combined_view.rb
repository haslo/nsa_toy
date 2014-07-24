class CreateCombinedView < ActiveRecord::Migration
  def change

    execute(
      <<-SQL
        create materialized view searchable_people as
        select
          people.id as id,
          people.name as "name",
          string_agg(paragraphs.text, ' ') as paragraphs,
          concat(
            people.id, ' ',
            people.name, ' ',
            string_agg(paragraphs.text, ' ')
          ) as document
        from people
        left join paragraphs
        on people.id = paragraphs.person_id
        group by people.id
    SQL
    )

    execute("create index document_index on searchable_people using gin(to_tsvector('english', document))")
    execute('create index document_trigram_index ON searchable_people USING gin(document gin_trgm_ops)')

  end
end
