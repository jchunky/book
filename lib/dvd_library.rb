class DvdLibrary
  Dvd = Struct.new(:title, :holds, :copies, :href, :year,
                   :rating, :availability_status, :audiences,
                   :content_type, :genre, :subject, :available)

  def dvds
    result = []
    (1..).each do |page|
      page_dvds = dvds_for_page(page)
      break if page_dvds.none?

      result.concat(page_dvds)
    end

    result.uniq(&:href)
      .sort_by { |d| -d.rating }
      .first(30)
  end

  private

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

    title = info["title"].to_s
    year = info["publicationDate"].to_i
    holds = avail["heldCopies"].to_i
    copies = avail["totalCopies"].to_i
    href = "/v2/record/#{bib["id"]}"
    rating = holds * copies

    Dvd.new(title, holds, copies, href, year, rating,
            avail["localisedStatus"].to_s,
            Array(info["audiences"]).join(", "),
            info["contentType"].to_s,
            Array(info["genreForm"]).join(", "),
            Array(info["subjectHeadings"]).join(", "),
            avail["availableCopies"].to_i)
  end
end
