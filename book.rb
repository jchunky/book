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

  RATING_CSS_CLASSES = {
    "G" => "rating-g",
    "PG" => "rating-pg",
    "PG-13" => "rating-pg13",
    "R" => "rating-r",
  }.freeze

  def genre_color(genre)
    GENRE_COLORS[genre] || "#444444"
  end

  def rated_pill(rated)
    css_class = RATING_CSS_CLASSES[rated]
    return "" unless css_class

    %(<span class="rating-pill #{css_class}">#{rated}</span>)
  end

  def display_book?(_book)
    true
  end

  def run
    @books = BookLibrary.new.books
      .select(&method(:display_book?))
      .sort_by { |b| [b.book_type, -b.rating, -b.year, b.title] }

    @movies = MovieLibrary.new.movies

    puts "Books: #{@books.count}, Movies: #{@movies.count}"

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
