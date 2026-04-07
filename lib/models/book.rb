# frozen_string_literal: true

module Models
  Book = Struct.new(
    :title,
    :holds,
    :copies,
    :href,
    :author,
    :year,
    :popularity,
    :availability_status,
    :audiences,
    :content_type,
    :available,
    :on_order,
    :genre,
    :jacket_url,
    :jacket_url_medium,
    :description,
  )
end
