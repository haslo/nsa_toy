class SearchesController < ApplicationController

  def show
    respond_to do |format|
      format.json do
        found_people = Person.search(params[:q]).map do |person|
          {
            id: person.id,
            name: person.name,
            href: person.href
          }
        end
        if found_people.count > 20
          found_people = found_people[0..19]
        end
        render status: 200, json: found_people
      end
    end
  end

end
