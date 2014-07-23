class SearchController < ApplicationController

  def show
    respond_to do |format|
      format.json do
        found_people = Person.search(params[:q])
        if found_people.count > 20
          found_people = found_people[0..19]
        end
        render status: 200, json: { html: render_to_string(action: 'show',
                                                           layout: false,
                                                           formats: [:html],
                                                           locals: {results: found_people}) }
      end
    end
  end

end
