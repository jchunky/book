# frozen_string_literal: true

require "active_support/all"
require "delegate"
require "erb"
require "json"
require "net/http"
require "uri"

require_relative "lib/loader"
Loader.setup

class Book
  def run
    books = Models::Book.all
    movies = Models::Movie.all

    puts "Books: #{books.count}, Movies: #{movies.count}"

    page = Presenters::CatalogPage.new(books:, movies:)
    File.write("index.html", page.render)
  end
end

Book.new.run
