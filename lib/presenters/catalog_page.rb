# frozen_string_literal: true

module Presenters
  class CatalogPage
    def initialize(books:, movies:)
      @books = books.map { Presenters::BookRow.new(it) }
      @movies = movies.map { Presenters::MovieRow.new(it) }
    end

    def book_count = @books.size
    def movie_count = @movies.size

    def render
      template = File.read("views/book.erb")
      ERB.new(template).result(binding)
    end
  end
end
