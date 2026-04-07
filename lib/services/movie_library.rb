# frozen_string_literal: true

module Services
  class MovieLibrary
    def movies
      search = Downloaders::BibliocommonsSearch.new do |page|
        url_for_page(page)
      end
      sorted = search.fetch_all { |bib| bib_to_movie(bib) }
        .sort_by { |m| -m.popularity.score }

      enrich_with_omdb(sorted)
        .select(&:keep?)
    end

    private

    def enrich_with_omdb(movies)
      omdb_client = Downloaders::Omdb.new
      movies.map do |movie|
        info = omdb_client.info(title: movie.title.to_s, year: movie.year)
        Models::Movie.new(biblio: movie.biblio, omdb: info)
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

      biblio = Models::BiblioRecord.from_bib(bib)

      Models::Movie.new(
        biblio:,
        omdb: Downloaders::Omdb::NO_INFO,
      )
    end
  end
end
