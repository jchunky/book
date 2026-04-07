# frozen_string_literal: true

module Models
  Book = Struct.new(
    :title,
    :copies_info,
    :href,
    :author,
    :year,
    :popularity,
    :audiences,
    :content_type,
    :genre,
    :jacket_url,
    :jacket_url_medium,
    :description,
  )
end
