# frozen_string_literal: true

module Models
  class Book < Struct.new(
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
  end
end
