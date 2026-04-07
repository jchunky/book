# frozen_string_literal: true

module Services
  class BookLibrary
    def initialize(filter: Services::BookFilter)
      @filter = filter
    end

    def books
      search = Downloaders::BibliocommonsSearch.new do |page|
        url_for_page(page)
      end
      search.fetch_all { |bib| bib_to_book(bib) }
        .select(&@filter)
        .sort_by { |b| -b.popularity.score }
        .first(30)
    end

    private

    def url_for_page(page)
      params = "?query=avlocation%3A%22Parkdale%22"
      params += "&searchType=bl&suppress=true"
      params += "&f_FORMAT=BK&f_CIRC=CIRC&f_PRIMARY_LANGUAGE=eng"
      params += "&page=#{page}" if page > 1
      "#{Downloaders::BibliocommonsSearch::BASE_URL}#{params}"
    end

    def bib_to_book(bib)
      return unless bib

      info = bib["briefInfo"] || {}
      avail = bib["availability"] || {}

      title = Models::CatalogTitle.new(
        title: info["title"].to_s,
        subtitle: info["subtitle"].to_s,
      )
      author = Array(info["authors"]).first.to_s
      year = info["publicationDate"].to_i
      holds = avail["heldCopies"].to_i
      copies = avail["totalCopies"].to_i
      available = avail["availableCopies"].to_i
      on_order = avail["onOrderCopies"].to_i
      href = "/v2/record/#{bib["id"]}"
      copies_info = Models::CopiesInfo.new(copies:, available:, holds:, on_order:)
      popularity = Models::PopularityScore.new(holds:, copies:)

      Models::Book.new(
        title:,
        copies_info:,
        href:,
        author:,
        year:,
        popularity:,
        audiences: Array(info["audiences"]).join(", "),
        content_type: info["contentType"].to_s,
        genre: Models::CallNumber.new(raw: info["callNumber"].to_s).genre,
        jacket_url: info.dig("jacket", "small").to_s,
        jacket_url_medium: info.dig("jacket", "medium").to_s,
        description: info["description"].to_s,
      )
    end
  end
end
