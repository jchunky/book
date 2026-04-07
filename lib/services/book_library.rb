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
        .sort_by { |b| -b.rating }
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

    def genre_from_call_number(call_number)
      if call_number.match?(/\A\d/)
        Models::Dewey.lookup(call_number)
      else
        call_number.split[0..-2].join(" ")
      end
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
      href = "/v2/record/#{bib["id"]}"
      rating = holds * copies # * (Date.today.year + 1 - year)

      Models::Book.new(
        title:,
        holds:,
        copies:,
        href:,
        author:,
        year:,
        rating:,
        availability_status: avail["localisedStatus"].to_s,
        audiences: Array(info["audiences"]).join(", "),
        content_type: info["contentType"].to_s,
        available: avail["availableCopies"].to_i,
        on_order: avail["onOrderCopies"].to_i,
        genre: genre_from_call_number(info["callNumber"].to_s),
        jacket_url: info.dig("jacket", "small").to_s,
        jacket_url_medium: info.dig("jacket", "medium").to_s,
        description: info["description"].to_s,
      )
    end
  end
end
