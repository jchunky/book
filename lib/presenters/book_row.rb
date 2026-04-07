# frozen_string_literal: true

module Presenters
  class BookRow
    delegate :title, :href, :author, :year, :genre,
             to: :@book
    delegate :holds, :copies, :available, :on_order,
             to: :copies_info

    CONTENT_TYPE_FLAGS = {
      "FICTION" => "F",
      "NONFICTION" => "",
    }.freeze
    def initialize(book)
      @book = book
    end

    def copies_info = @book.copies_info

    def on_order
      copies_info.on_order unless copies_info.on_order.zero?
    end

    def rating = @book.popularity.score

    def rating_class
      "number#{" low-rating" if @book.popularity.low?} rating"
    end

    def availability_style
      copies_info.availability_style
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
