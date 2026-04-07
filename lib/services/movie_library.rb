# frozen_string_literal: true

module Services
  class MovieLibrary
    def initialize(filter: Services::MovieFilter)
      @filter = filter
    end

    def movies
      search = Downloaders::BibliocommonsSearch.new do |page|
        url_for_page(page)
      end
      sorted = search.fetch_all { |bib| bib_to_movie(bib) }
        .sort_by { |m| -m.popularity.score }

      enrich_with_omdb(sorted)
        .select(&@filter)
    end

    private

    def enrich_with_omdb(movies)
      omdb_client = Downloaders::Omdb.new
      movies.map do |movie|
        info = omdb_client.info(title: movie.title.to_s, year: movie.year)
        Models::Movie.new(**movie.to_h, omdb: info)
      end
    end

    def url_for_page(page)
      params = "?query=isolanguage%3A%22eng%22%20formatcode%3A(DVD%20)"
      params += "&searchType=bl&suppress=true"
      params += "&f_PRIMARY_LANGUAGE=eng&f_CIRC=CIRC"
      params += "&f_GENRE_HEADINGS=Feature%20films"
      params += "&sort=newly_acquired"
      params += "&page=#{page}" if page > 1
      "#{Downloaders::BibliocommonsSearch::BASE_URL}#{params}"
    end

    def bib_to_movie(bib)
      return unless bib

      info = bib["briefInfo"] || {}
      avail = bib["availability"] || {}

      title = Models::CatalogTitle.new(
        title: info["title"].to_s,
        subtitle: info["subtitle"].to_s,
      )
      year = info["publicationDate"].to_i
      holds = avail["heldCopies"].to_i
      copies = avail["totalCopies"].to_i
      available = avail["availableCopies"].to_i
      on_order = avail["onOrderCopies"].to_i
      href = "/v2/record/#{bib["id"]}"
      copies_info = Models::CopiesInfo.new(copies:, available:, holds:, on_order:)
      popularity = Models::PopularityScore.new(holds:, copies:)

      Models::Movie.new(
        title:,
        copies_info:,
        href:,
        year:,
        popularity:,
        audiences: Array(info["audiences"]).join(", "),
        content_type: info["contentType"].to_s,
        jacket_url: info.dig("jacket", "small").to_s,
        jacket_url_medium: info.dig("jacket", "medium").to_s,
        description: info["description"].to_s,
        omdb: Downloaders::Omdb::NO_INFO,
      )
    end
  end
end
