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

    def popularity = @movie.popularity.score

    def popularity_class
      "number#{" low-popularity" if @movie.popularity.low?} popularity"
    end

    def availability_style
      copies_info.availability_style
    end

    def title_class
      @movie.must_see? ? nil : "not-must-see"
    end

    def rated_pill
      Models::ContentRating.for(@movie.rated)&.to_html || ""
    end

    def box_office
      @movie.box_office if @movie.box_office.to_i > 0
    end

    def metacritic_html
      return "" if @movie.metacritic.empty?

      %(<a href="#{metacritic_url}"><span class="mc">#{@movie.metacritic}</span></a>)
    end

    def audience_pill
      Models::Audience.for(@movie)&.to_html || ""
    end
  end
end
