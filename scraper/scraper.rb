require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pg'

# built with a little help from http://ruby.bastardsbook.com/chapters/web-crawling/

BASE_WIKIPEDIA_URL = "http://en.wikipedia.org"
LIST_URL = "#{BASE_WIKIPEDIA_URL}/wiki/List_of_Nobel_laureates"
MAX_NUMBER_OF_PEOPLE = 1000000
MAX_PARAGRAPHS_PER_PERSON = 10
NAME_REGEX = /\A[A-Z]([a-zàáâäãåèéêëìíîïòóôöõøùúûüÿýñçčšž]+|\.)([A-Z]\.)? [A-Z][a-zàáâäãåèéêëìíîïòóôöõøùúûüÿýñçčšž]+\Z/
WIKI_REGEX = /\/wiki\//
MAX_STACK_LEVEL = 5

def do_scrape(page, conn, stack_level = 0)
  sleep 0.1
  hrefs = extract_hrefs_from_page(page)
  hrefs.sort{|_,_| Random.rand(3) - 1}.each do |text, href|
    number_of_people = conn.exec('select count(*) from people')[0]['count'].to_i
    number_of_paragraphs = conn.exec('select count(*) from paragraphs')[0]['count'].to_i
    if number_of_people < MAX_NUMBER_OF_PEOPLE && stack_level <= MAX_STACK_LEVEL
      print "\rstack: #{stack_level} people: #{number_of_people} paragraphs: #{number_of_paragraphs}"
      add_person_data_to_database(conn, href, stack_level, text)
    end
  end
end

def extract_hrefs_from_page(page)
  Hash[page.css("#mw-content-text a").map do |a|
    if a.text =~ NAME_REGEX && a['href'] =~ WIKI_REGEX
      [a.text, a['href']]
    else
      nil
    end
  end.compact.uniq]
end

def add_person_data_to_database(conn, href, stack_level, text)
  person_id = store_person(conn, text, href)
  if person_id
    begin
      next_page = Nokogiri::HTML(open("#{BASE_WIKIPEDIA_URL}#{href}"))
      paragraph_count = 0
      next_page.css("#mw-content-text p").each do |paragraph|
        paragraph_text = paragraph.text.gsub(/\[\d+\]/, '').gsub("'", "''").strip
        unless paragraph_text.strip.length == 0 || paragraph_count >= MAX_PARAGRAPHS_PER_PERSON
          store_paragraph(conn, person_id, paragraph_text)
          paragraph_count += 1
        end
      end
      do_scrape(next_page, conn, stack_level + 1)
    rescue OpenURI::HTTPError
      # ignore dead links
    end
  end
end

def store_person(conn, name, href)
  begin
    conn.exec(
      <<-SQL
      insert into people("name", href, created_at, updated_at)
      select '#{name}', '#{BASE_WIKIPEDIA_URL}#{href}', NOW(), NOW()
      where not exists
      (select id from people where "name" = '#{name}')
      returning id
    SQL
    )[0]['id']
  rescue IndexError
    # this only happens if no id is returned, thus no record was stored, thus the person already exists
    false
  end
end

def store_paragraph(conn, person_id, text)
  conn.exec(
    <<-SQL
    insert into paragraphs(person_id, text, created_at, updated_at)
    select #{person_id}, '#{text}', NOW(), NOW()
    returning id
  SQL
  )[0]['id']
end

conn = PGconn.connect("localhost", 5432, "", "", "nsa_toy_development")
conn.exec('delete from people')
conn.exec('delete from paragraphs')
start_page = Nokogiri::HTML(open(LIST_URL))
do_scrape(start_page, conn)
print "\n"
