# frozen_string_literal: true

class BookListLibrary
  BookListEntry = Data.define(
    :title, :call_number, :dewey_class, :dewey_division, :href,
  )

  def initialize(books)
    @books = books
  end

  def entries
    titles.filter_map { |title| find_book(title) }
  end

  private

  def titles
    File.readlines("input/book-list.txt", chomp: true)
      .reject(&:empty?)
  end

  def find_book(title)
    book = @books.find { |b| b.title.to_s.casecmp?(title) }
    book_to_entry(title, book)
  end

  def book_to_entry(title, book)
    return unless book

    BookListEntry.new(
      title:, call_number: book.call_number,
      dewey_class: Dewey.class_lookup(book.call_number),
      dewey_division: Dewey.lookup(book.call_number),
      href: book.href,
    )
  end
end
