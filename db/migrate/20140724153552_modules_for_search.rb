class ModulesForSearch < ActiveRecord::Migration
  def change

    execute('create extension if not exists pg_trgm')
    execute('create extension if not exists fuzzystrmatch')

    execute('create index name_trigram_index ON people USING gin(name gin_trgm_ops)')
    execute('create index text_trigram_index ON paragraphs USING gin(text gin_trgm_ops)')

  end
end
