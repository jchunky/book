# frozen_string_literal: true

module Presenters
  class BookRow
    include CatalogRow

    delegate :title, :href, :author, :year, :genre,
             to: :catalog_item

    CONTENT_TYPE_FLAGS = {
      "FICTION" => "F",
      "NONFICTION" => "",
    }.freeze

    def initialize(book)
      @book = book
    end

    def genre_html
      return "" if genre.empty?

      Models::Genre.for(genre).to_html
    end

    def fiction_flag
      CONTENT_TYPE_FLAGS.fetch(catalog_item.content_type)
    end

    private

    def catalog_item = @book
  end
end
