# frozen_string_literal: true

module Presenters
  class MovieRow
    RATING_CSS_CLASSES = {
      "G" => "rating-g",
      "PG" => "rating-pg",
      "PG-13" => "rating-pg13",
      "R" => "rating-r",
    }.freeze

    AUDIENCE_CSS_CLASSES = {
      "JUVENILE" => "audience-juvenile",
      "TEEN" => "audience-teen",
      "ADULT" => "audience-adult",
    }.freeze

    delegate :holds, :copies, :available, :display_title, :display_year,
             :href, :runtime, :genre, :rotten_tomatoes,
             :rotten_tomatoes_url, :metacritic_url, to: :@movie

    def initialize(movie)
      @movie = movie
    end

    def on_order
      @movie.on_order unless @movie.on_order.zero?
    end

    def rating = @movie.rating

    def low_rating? = @movie.rating < 100

    def rating_class
      "number#{' low-rating' if low_rating?} rating"
    end

    def availability_class
      return "avail-none" if available.zero?
      return "avail-low" if copies.positive? && available <= copies / 4
      "avail-ok" if available.positive?
    end

    def title_class
      @movie.must_see? ? nil : "not-must-see"
    end

    def rated_pill
      css_class = RATING_CSS_CLASSES[@movie.rated]
      return "" unless css_class

      %(<span class="#{css_class}">#{@movie.rated}</span>)
    end

    def box_office
      @movie.box_office if @movie.box_office.to_i > 0
    end

    def metacritic_html
      return "" if @movie.metacritic.empty?

      %(<a href="#{metacritic_url}"><span class="mc">#{@movie.metacritic}</span></a>)
    end

    def audience_pill
      label = if @movie.juvenile? then "JUVENILE"
              elsif @movie.teen? then "TEEN"
              end
      return "" unless label

      css_class = AUDIENCE_CSS_CLASSES[label]
      %(<span class="#{css_class}">#{label[0]}</span>)
    end
  end
end
