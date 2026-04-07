# frozen_string_literal: true

module Presenters
  class BookRow
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

    def availability_style
      avail = Availability.for(available:, copies:)
      return "" unless avail

      "color: #{avail.text_color}; background-color: #{avail.bg_color};"
    end

    def genre_html
      return "" if genre.empty?

      g = Genre.for(genre)
      %(<span style="color: #{g.color}; font-weight: bold;">#{g.name}</span>)
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
