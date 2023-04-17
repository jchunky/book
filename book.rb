require "active_support/all"
require "erb"
require "net/http"
require "nokogiri"
require "uri"
require "yaml/store"
Dir["lib/*.rb"].each { |f| require_relative f }

class Book
  def display_book?(book)
    true
  end

  def run
    @books = Library.new.books
      .select(&method(:display_book?))
      .sort_by { |b| [b.book_type, -b.rating, -b.year, b.title] }

    p @books.count

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
