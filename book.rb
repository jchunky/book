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
    "FICTION" => "#7B6B4B",
    "MYSTERY" => "#2E5A88",
    "ROMANCE" => "#A8435A",
    "SCI-FI" => "#2A7B5F",
    "HORROR" => "#6B3A6B",
  }.freeze

  def genre_color(genre)
    GENRE_COLORS[genre] || "#555555"
  end

  def display_book?(_book)
    true
  end

  def run
    @books = BookLibrary.new.books
      .select(&method(:display_book?))
      .sort_by { |b| [b.book_type, -b.rating, -b.year, b.title] }

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
