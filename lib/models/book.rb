# frozen_string_literal: true

module Models
  class Book < Data.define(
    :biblio,
    :author,
    :genre,
  )
    delegate :title,
             :copies_info,
             :href,
             :year,
             :popularity,
             :audiences,
             :content_type,
             :jacket_url,
             :jacket_url_medium,
             :description,
             to: :biblio

    def self.all
      Services::BookLibrary.new.books
    end

    def keep?
      Services::BookFilter.keep?(self)
    end
  end
end
