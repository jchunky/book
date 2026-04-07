# frozen_string_literal: true

class MovieLibrary
  Movie = Struct.new(
    :title,
    :holds,
    :copies,
    :href,
    :year,
    :rating,
    :availability_status,
    :audiences,
    :content_type,
    :available,
    :on_order,
    :jacket_url,
    :jacket_url_medium,
    :description,
    :omdb,
  ) do
    delegate :rated,
             :runtime,
             :genre,
             :box_office,
             :rotten_tomatoes,
             :metacritic,
             to: :omdb

    def certified_fresh? = rotten_tomatoes.to_i >= 75 && !certified_fresh_excluded?
    def must_see? = metacritic.to_i >= 80 && !must_see_excluded?
    def juvenile? = Audience.juvenile?(self)
    def teen? = Audience.teen?(self)
    def adult? = Audience.adult?(self)
    def animation? = Genre.animation?(self)
    def display_title = omdb.title.empty? ? title : omdb.title
    def display_year = omdb.year.empty? ? year : omdb.year
    def rotten_tomatoes_url = search_url("site:rottentomatoes.com/m", display_title, display_year)
    def metacritic_url = search_url("site:metacritic.com/movie", display_title, display_year)
    def must_see_excluded? = MUST_SEE_EXCLUDED_MOVIE_TITLES.include?(display_title)
    def certified_fresh_excluded? = CERTIFIED_FRESH_EXCLUDED_MOVIE_TITLES.include?(display_title)

    private

    def search_url(site_filter, title, year)
      query = URI.encode_www_form_component("#{site_filter} #{title} #{year}")
      "https://www.google.com/search?btnI&q=#{query}"
    end
  end

  def initialize(filter: MovieFilter)
    @filter = filter
  end

  def movies
    search = BibliocommonsSearch.new do |page|
      url_for_page(page)
    end
    sorted = search.fetch_all { |bib| bib_to_movie(bib) }
      .sort_by { |m| -m.rating }

    enrich_with_omdb(sorted)
      .select(&@filter)
  end

  private

  def enrich_with_omdb(movies)
    omdb_client = Omdb.new
    movies.map do |movie|
      info = omdb_client.info(title: movie.title.to_s, year: movie.year)
      Movie.new(**movie.to_h, omdb: info)
    end
  end

  def url_for_page(page)
    params = "?query=isolanguage%3A%22eng%22%20formatcode%3A(DVD%20)"
    params += "&searchType=bl&suppress=true"
    params += "&f_PRIMARY_LANGUAGE=eng&f_CIRC=CIRC"
    params += "&f_GENRE_HEADINGS=Feature%20films"
    params += "&sort=newly_acquired"
    params += "&page=#{page}" if page > 1
    "#{BibliocommonsSearch::BASE_URL}#{params}"
  end

  def bib_to_movie(bib)
    return unless bib

    info = bib["briefInfo"] || {}
    avail = bib["availability"] || {}

    title = CatalogTitle.new(
      title: info["title"].to_s,
      subtitle: info["subtitle"].to_s,
    )
    year = info["publicationDate"].to_i
    holds = avail["heldCopies"].to_i
    copies = avail["totalCopies"].to_i
    href = "/v2/record/#{bib["id"]}"
    rating = holds * copies

    Movie.new(
      title:,
      holds:,
      copies:,
      href:,
      year:,
      rating:,
      availability_status: avail["localisedStatus"].to_s,
      audiences: Array(info["audiences"]).join(", "),
      content_type: info["contentType"].to_s,
      available: avail["availableCopies"].to_i,
      on_order: avail["onOrderCopies"].to_i,
      jacket_url: info.dig("jacket", "small").to_s,
      jacket_url_medium: info.dig("jacket", "medium").to_s,
      description: info["description"].to_s,
      omdb: Omdb::NO_INFO,
    )
  end
end
