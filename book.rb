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
    GENRE_COLORS[genre] || "#444444"
  end

  def display_book?(_book)
    true
  end

  def run
    @books = BookLibrary.new.books
      .select(&method(:display_book?))
      .sort_by { |b| [b.book_type, -b.rating, -b.year, b.title] }

    @dvds = DvdLibrary.new.dvds

    puts "Books: #{@books.count}, DVDs: #{@dvds.count}"

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
