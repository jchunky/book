# frozen_string_literal: true

require "active_support/all"
require "erb"
require "json"
require "net/http"
require "uri"
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

  AUDIENCE_CSS_CLASSES = {
    "JUVENILE" => "audience-juvenile",
    "TEEN" => "audience-teen",
    "ADULT" => "audience-adult",
  }.freeze

  def genre_color(genre)
    GENRE_COLORS[genre] || "#444444"
  end

  def rated_pill(rated)
    css_class = RATING_CSS_CLASSES[rated]
    return "" unless css_class

    %(<span class="rating-pill #{css_class}">#{rated}</span>)
  end

  def availability_class(available, copies)
    return "avail-none" if available.zero?
    return "avail-low" if copies.positive? && available <= copies / 4
    "avail-ok" if available.positive?
  end

  def audience_pill(item)
    label = if item.juvenile? then "JUVENILE"
            elsif item.teen? then "TEEN"
            elsif item.adult? then "ADULT"
            end
    return "" unless label

    css_class = AUDIENCE_CSS_CLASSES[label]
    %(<span class="audience-pill #{css_class}">#{label.capitalize}</span>)
  end

  def display_book?(_book)
    true
  end

  def run
    @books = BookLibrary.new.books
      .select(&method(:display_book?))
      .sort_by { |b| [-b.rating, -b.year, b.title] }

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
