# frozen_string_literal: true

module Services
  class BookLibrary
    def books
      search = Downloaders::BibliocommonsSearch.new do |page|
        url_for_page(page)
      end
      search.fetch_all { |bib| bib_to_book(bib) }
        .select(&:keep?)
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
      biblio = Models::BiblioRecord.from_bib(bib)

      Models::Book.new(
        biblio:,
        author: Array(info["authors"]).first.to_s,
        genre: Models::CallNumber.new(raw: info["callNumber"].to_s).genre,
      )
    end
  end
end
