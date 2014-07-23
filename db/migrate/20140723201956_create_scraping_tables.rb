class CreateScrapingTables < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name
      t.string :href
      t.timestamps
    end

    create_table :paragraphs do |t|
      t.references :person, index: true
      t.text :text
      t.timestamps
    end
  end
end
