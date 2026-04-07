# frozen_string_literal: true

module Presenters
  class BookRow
    delegate :holds,
             :copies,
             :available,
             :title,
             :href,
             :author,
             :year,
             :genre,
             to: :@book

    CONTENT_TYPE_FLAGS = {
      "FICTION" => "F",
      "NONFICTION" => "",
    }.freeze
    def initialize(book)
      @book = book
    end

    def on_order
      @book.on_order unless @book.on_order.zero?
    end

    def rating = @book.popularity.score

    def rating_class
      "number#{" low-rating" if @book.popularity.low?} rating"
    end

    def availability_style
      Models::Availability.style(available:, copies:)
    end

    def genre_html
      return "" if genre.empty?

      g = Models::Genre.for(genre)
      %(<span style="color: #{g.color}; font-weight: bold;">#{g.name}</span>)
    end

    def audience_pill
      audience = Models::Audience.for(@book)
      return "" if audience.abbr.empty?

      %(<span style="color: #{audience.color}; font-weight: bold;">#{audience.abbr}</span>)
    end

    def fiction_flag
      CONTENT_TYPE_FLAGS.fetch(@book.content_type)
    end
  end
end
