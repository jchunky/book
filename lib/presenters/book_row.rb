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
      audience = Audience.for(@book)
      return "" if audience.abbr.empty?

      %(<span style="color: #{audience.color}; font-weight: bold;">#{audience.abbr}</span>)
    end

    CONTENT_TYPE_FLAGS = {
      "FICTION" => "F",
      "NONFICTION" => "",
    }.freeze

    def fiction_flag
      CONTENT_TYPE_FLAGS.fetch(@book.content_type)
    end
  end
end
