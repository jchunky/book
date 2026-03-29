# frozen_string_literal: true

require "active_support/all"
require "erb"
require "json"
require "net/http"
require "pstore"
require "uri"
require "yaml/store"
Dir["lib/*.rb"].each { |f| require_relative f }

class Book
  GENRE_COLORS = {
    "FICTION" => "#888888",
    "MYSTERY" => "#2979FF",
    "ROMANCE" => "#E91E63",
    "SCIENCE FICTION" => "#00BFA5",
    "HORROR" => "#AA00FF",
  }.freeze

  def genre_color(genre)
    GENRE_COLORS[genre] || "#000000"
  end

  def display_book?(book)
    @nyt.best_seller?(book.title.to_s)
  end

  def run
    @nyt = NytBestSellers.new
    @books = BookLibrary.new.books
      .select(&method(:display_book?))
      .sort_by { |b| [b.book_type, -b.rating, -b.year, b.title.to_s] }

    @dvds = DvdLibrary.new.dvds

    p @books.count
    p @dvds.count

    write_output
  end

  private

  def write_output
    template = File.read("views/book.erb")
    html = ERB.new(template).result(binding)
    File.write("index.html", html)
  end
end

Book.new.run
