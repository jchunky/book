# frozen_string_literal: true

module Models
  Book = Struct.new(
    :biblio,
    :author,
    :genre,
  ) do
    delegate :title, :copies_info, :href, :year, :popularity,
             :audiences, :content_type,
             :jacket_url, :jacket_url_medium, :description,
             to: :biblio
  end
end
