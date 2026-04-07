# frozen_string_literal: true

module Presenters
  class MovieRow
    include CatalogRow

    delegate :display_title,
             :display_year,
             :href,
             :runtime,
             :genre,
             :rotten_tomatoes,
             :rotten_tomatoes_url,
             :metacritic_url,
             to: :catalog_item

    def initialize(movie)
      @movie = movie
    end

    def title_class
      catalog_item.must_see? ? nil : "not-must-see"
    end

    def rated_pill
      Models::ContentRating.for(catalog_item.rated)&.to_html || ""
    end

    def box_office
      catalog_item.box_office if catalog_item.box_office.to_i > 0
    end

    def metacritic_html
      return "" if catalog_item.metacritic.empty?

      %(<a href="#{metacritic_url}"><span class="mc">#{catalog_item.metacritic}</span></a>)
    end

    private

    def catalog_item = @movie
  end
end
