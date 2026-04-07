# frozen_string_literal: true

module Services
  class BookFilter < SimpleDelegator
    def self.keep?(item) = new(item).keep?

    def keep?
      content_type == "NONFICTION" ||
        Models::Genre.science_fiction?(self)
    end
  end
end
