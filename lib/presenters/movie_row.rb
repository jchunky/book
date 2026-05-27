# frozen_string_literal: true

module Presenters
  class MovieRow
    include CatalogRow

    delegate :display_title,
             :display_year,
             :href,
             :runtime,
             :genre,
             :director,
             :omdb_status,
             :rotten_tomatoes_url,
             :metacritic_url,
             to: :catalog_item

    def initialize(movie)
      @movie = movie
    end

    def title_class
      classes = []
      classes << "not-must-see" unless catalog_item.must_see?
      classes << "loved" if catalog_item.loved?
      classes << "disliked" if catalog_item.disliked?
      classes.join(" ").presence
    end

    def rated_pill
      Models::ContentRating.for(catalog_item.rated)&.to_html || ""
    end

    def box_office
      catalog_item.box_office if catalog_item.box_office.to_i > 0
    end

    def language_pill
      Models::Language.for(catalog_item.primary_language).to_html
    end

    def country
      catalog_item.country == "United States" ? "" : catalog_item.country
    end

    def rotten_tomatoes_html
      return "" if catalog_item.rotten_tomatoes.empty?

      %(<a href="#{rotten_tomatoes_url}"><span class="rt">#{catalog_item.rotten_tomatoes}</span></a>)
    end

    def metacritic_html
      return "" if catalog_item.metacritic.empty?

      %(<a href="#{metacritic_url}"><span class="mc">#{catalog_item.metacritic}</span></a>)
    end

    private

    def catalog_item = @movie
  end
end
