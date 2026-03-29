# frozen_string_literal: true

class DvdLibrary
  Dvd = Struct.new(
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

    def certified_fresh? = rotten_tomatoes.to_i >= 75
    def must_see? = metacritic.to_i >= 80
    def juvenile? = audiences.include?("JUVENILE")
    def teen? = audiences.include?("TEEN")
    def adult? = audiences.include?("ADULT")
    def animation? = genre.include?("Animation")

    def display_title
      omdb.title.empty? ? title : omdb.title
    end

    def display_year
      omdb.year.empty? ? year : omdb.year
    end

    def keep?
      return false if animation?

      teen? && certified_fresh?
      # adult? && must_see?
      # true
    end
  end

  def dvds
    search = BibliocommonsSearch.new do |page|
      url_for_page(page)
    end
    sorted = search.fetch_all { |bib| bib_to_dvd(bib) }
      .sort_by { |d| -d.rating }

    enrich_with_omdb(sorted)
      .select(&:keep?)
  end

  private

  def enrich_with_omdb(dvds)
    omdb_client = Omdb.new
    dvds.map do |dvd|
      info = omdb_client.info(title: dvd.title.to_s, year: dvd.year)
      Dvd.new(**dvd.to_h, omdb: info)
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

  def bib_to_dvd(bib)
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

    Dvd.new(
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
