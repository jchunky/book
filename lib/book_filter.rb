# frozen_string_literal: true

class BookFilter
  def call(book)
    book.content_type == "NONFICTION" ||
      Genre.science_fiction?(book)
  end

  def to_proc = method(:call).to_proc
end
