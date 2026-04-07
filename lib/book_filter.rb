# frozen_string_literal: true

class BookFilter
  def call(book)
    book.content_type == "NONFICTION" ||
      book.genre == "SCIENCE FICTION"
  end

  def to_proc = method(:call).to_proc
end
