class DvdLibrary
  Dvd = Struct.new(:title, :holds, :copies, :href, :year,
                   :rating, :availability_status, :audiences,
                   :content_type, :available, :on_order,
                   :jacket_url, :jacket_url_medium,
                   :description, :rotten_tomatoes, :metacritic,
                   :omdb_year, :rated, :runtime, :genre,
                   :box_office) do
    def certified_fresh? = rotten_tomatoes.to_i >= 75
    def must_see? = metacritic.to_i >= 80
    def teen? = audiences.include?("TEEN")
    def adult? = audiences.include?("ADULT")
  end

  def dvds
    result = []
    (1..).each do |page|
      page_dvds = dvds_for_page(page)
      break if page_dvds.none?

      result.concat(page_dvds)
    end

    teens = result.uniq(&:href)
      .sort_by { |d| -d.rating }
    enrich_with_omdb(teens)
      .select(&method(:keep?))
      .first(30)
  end

  private

  def keep?(dvd)
    dvd.teen? && dvd.certified_fresh?
  end

  def enrich_with_omdb(dvds)
    omdb = Omdb.new
    dvds.each do |dvd|
      info = omdb.info(title: dvd.title, year: dvd.year)
      dvd.rotten_tomatoes = info.rotten_tomatoes
      dvd.metacritic = info.metacritic
      dvd.omdb_year = info.year
      dvd.rated = info.rated
      dvd.runtime = info.runtime
      dvd.genre = info.genre
      dvd.box_office = info.box_office
    end
  rescue Omdb::RateLimitError
    warn "OMDb daily limit reached, skipping remaining lookups"
    dvds
  end

  def dvds_for_page(page)
    url = url_for_page(page)
    CachedFile.new(url:, crawl_delay: 1).read do |content|
      data = JSON.parse(content)
      bibs = data.dig("entities", "bibs") || {}
      ids = data.dig("catalogSearch", "results")
        &.map { |r| r["representative"] } || []
      ids.filter_map { |id| bib_to_dvd(bibs[id]) }
    end
  rescue StandardError
    []
  end

  def url_for_page(page)
    base = "https://gateway.bibliocommons.com/v2"
    base += "/libraries/tpl/bibs/search"
    params = "?query=isolanguage%3A%22eng%22%20formatcode%3A(DVD%20)"
    params += "&searchType=bl&suppress=true"
    params += "&f_PRIMARY_LANGUAGE=eng&f_CIRC=CIRC"
    params += "&f_GENRE_HEADINGS=Feature%20films"
    params += "&sort=newly_acquired"
    params += "&page=#{page}" if page > 1
    "#{base}#{params}"
  end

  def bib_to_dvd(bib)
    return unless bib

    info = bib["briefInfo"] || {}
    avail = bib["availability"] || {}

    subtitle = info["subtitle"].to_s
    title = info["title"].to_s
    title = "#{title}: #{subtitle}" unless subtitle.empty?
    year = info["publicationDate"].to_i
    holds = avail["heldCopies"].to_i
    copies = avail["totalCopies"].to_i
    href = "/v2/record/#{bib["id"]}"
    rating = holds * copies

    Dvd.new(title, holds, copies, href, year, rating,
            avail["localisedStatus"].to_s,
            Array(info["audiences"]).join(", "),
            info["contentType"].to_s,
            avail["availableCopies"].to_i,
            avail["onOrderCopies"].to_i,
            info.dig("jacket", "small").to_s,
            info.dig("jacket", "medium").to_s,
            info["description"].to_s)
  end
end
