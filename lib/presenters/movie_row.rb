# frozen_string_literal: true

module Presenters
  class MovieRow
    delegate :display_title, :display_year, :href,
             :runtime, :genre,
             :rotten_tomatoes, :rotten_tomatoes_url, :metacritic_url,
             to: :@movie
    delegate :holds, :copies, :available, :on_order,
             to: :copies_info

    def initialize(movie)
      @movie = movie
    end

    def copies_info = @movie.copies_info

    def on_order
      copies_info.on_order unless copies_info.on_order.zero?
    end

    def rating = @movie.popularity.score

    def rating_class
      "number#{" low-rating" if @movie.popularity.low?} rating"
    end

    def availability_style
      copies_info.availability_style
    end

    def title_class
      @movie.must_see? ? nil : "not-must-see"
    end

    def rated_pill
      content_rating = Models::ContentRating.for(@movie.rated)
      return "" unless content_rating

      %(<span style="color: #{content_rating.color}; font-weight: bold;">#{content_rating.name}</span>)
    end

    def box_office
      @movie.box_office if @movie.box_office.to_i > 0
    end

    def metacritic_html
      return "" if @movie.metacritic.empty?

      %(<a href="#{metacritic_url}"><span class="mc">#{@movie.metacritic}</span></a>)
    end

    def audience_pill
      audience = Models::Audience.for(@movie)
      return "" if audience.abbr.empty?

      %(<span style="color: #{audience.color}; font-weight: bold;">#{audience.abbr}</span>)
    end
  end
end
