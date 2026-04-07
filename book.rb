# frozen_string_literal: true

require "active_support/all"
require "erb"
require "json"
require "net/http"
require "uri"
Dir["lib/**/*.rb"].each { |f| require_relative f }

class Book
  def run
    books = BookLibrary.new.books
      .sort_by { |b| [-b.rating, -b.year, b.title] }

    movies = MovieLibrary.new.movies

    puts "Books: #{books.count}, Movies: #{movies.count}"

    page = Presenters::CatalogPage.new(books:, movies:)
    File.write("index.html", page.render)
  end
end

Book.new.run
