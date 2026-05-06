# frozen_string_literal: true

module Models
  class BiblioRecord < Data.define(
    :title,
    :copies_info,
    :href,
    :year,
    :popularity,
    :audiences,
    :content_type,
    :genre_form,
    :jacket_url,
    :jacket_url_medium,
    :description,
  )
    def self.from_bib(bib)
      info = bib["briefInfo"] || {}
      avail = bib["availability"] || {}

      holds = avail["heldCopies"].to_i
      copies = avail["totalCopies"].to_i
      available = avail["availableCopies"].to_i
      on_order = avail["onOrderCopies"].to_i

      new(
        title: CatalogTitle.new(
          title: info["title"].to_s,
          subtitle: info["subtitle"].to_s,
        ),
        copies_info: CopiesInfo.new(copies:, available:, holds:, on_order:),
        href: "/v2/record/#{bib["id"]}",
        year: info["publicationDate"].to_i,
        popularity: PopularityScore.new(holds:, copies:),
        audiences: Array(info["audiences"]).join(", "),
        content_type: info["contentType"].to_s,
        genre_form: Array(info["genreForm"]),
        jacket_url: info.dig("jacket", "small").to_s,
        jacket_url_medium: info.dig("jacket", "medium").to_s,
        description: info["description"].to_s,
      )
    end
  end
end
