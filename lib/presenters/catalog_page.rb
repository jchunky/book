# frozen_string_literal: true

module Presenters
  class CatalogPage
    GENRE_COLORS = {
      "FICTION" => "#6b7280",
      "MYSTERY" => "#2563eb",
      "ROMANCE" => "#e11d48",
      "SCIENCE FICTION" => "#0d9488",
      "HORROR" => "#9333ea",
    }.freeze

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

    def initialize(books:, movies:)
      @books = books
      @movies = movies
    end

    def book_count = @books.size
    def movie_count = @movies.size

    def genre_color(genre)
      GENRE_COLORS[genre] || "#444444"
    end

    def rated_pill(rated)
      css_class = RATING_CSS_CLASSES[rated]
      return "" unless css_class

      %(<span class="#{css_class}">#{rated}</span>)
    end

    def availability_class(available, copies)
      return "avail-none" if available.zero?
      return "avail-low" if copies.positive? && available <= copies / 4
      "avail-ok" if available.positive?
    end

    def audience_pill(item)
      label = if item.juvenile? then "JUVENILE"
              elsif item.teen? then "TEEN"
              end
      return "" unless label

      css_class = AUDIENCE_CSS_CLASSES[label]
      %(<span class="#{css_class}">#{label[0]}</span>)
    end

    def render
      template = File.read("views/book.erb")
      ERB.new(template).result(binding)
    end
  end
end
