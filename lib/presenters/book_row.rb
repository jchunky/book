# frozen_string_literal: true

module Presenters
  class BookRow
    GENRE_COLORS = {
      "FICTION" => "#6b7280",
      "MYSTERY" => "#2563eb",
      "ROMANCE" => "#e11d48",
      "SCIENCE FICTION" => "#0d9488",
      "HORROR" => "#9333ea",
    }.freeze

    AUDIENCE_CSS_CLASSES = {
      "JUVENILE" => "audience-juvenile",
      "TEEN" => "audience-teen",
      "ADULT" => "audience-adult",
    }.freeze

    delegate :holds, :copies, :available, :title, :href,
             :author, :year, :genre, to: :@book

    def initialize(book)
      @book = book
    end

    def on_order
      @book.on_order unless @book.on_order.zero?
    end

    def rating = @book.rating

    def low_rating? = @book.rating < 100

    def rating_class
      "number#{' low-rating' if low_rating?} rating"
    end

    def availability_class
      return "avail-none" if available.zero?
      return "avail-low" if copies.positive? && available <= copies / 4
      "avail-ok" if available.positive?
    end

    def genre_html
      return "" if genre.empty?

      color = GENRE_COLORS[genre] || "#444444"
      %(<span style="color: #{color}; font-weight: bold;">#{genre}</span>)
    end

    def audience_pill
      label = if @book.juvenile? then "JUVENILE"
              elsif @book.teen? then "TEEN"
              end
      return "" unless label

      css_class = AUDIENCE_CSS_CLASSES[label]
      %(<span class="#{css_class}">#{label[0]}</span>)
    end

    def fiction_flag
      "F" unless @book.content_type == "NONFICTION"
    end
  end
end
