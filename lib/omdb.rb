class Omdb
  Info = Data.define(:year, :rated, :runtime, :genre, :box_office,
                     :rotten_tomatoes, :metacritic)

  NO_INFO = Info.new(year: "", rated: "", runtime: "", genre: "",
                     box_office: "", rotten_tomatoes: "", metacritic: "")

  def info(title:, year:)
    result = info_for(title:, year:)
    return result unless result == NO_INFO

    info_for(title:)
  end

  private

  def info_for(title:, year: nil)
    url = url_for(title:, year:)
    CachedFile.new(url:, crawl_delay: 1).read do |content|
      parse_info(JSON.parse(content))
    end
  rescue StandardError => e
    warn "OMDb lookup failed for '#{title}': #{e.message}"
    NO_INFO
  end

  def parse_info(data)
    return NO_INFO unless data["Response"] == "True"

    ratings = Array(data["Ratings"])
    Info.new(
      year: data["Year"].to_s,
      rated: na_to_empty(data["Rated"]),
      runtime: na_to_empty(data["Runtime"]),
      genre: data["Genre"].to_s,
      box_office: data["BoxOffice"].to_s,
      rotten_tomatoes: rating_value(ratings, "Rotten Tomatoes"),
      metacritic: rating_value(ratings, "Metacritic")
    )
  end

  def na_to_empty(value)
    value = value.to_s
    value == "N/A" ? "" : value
  end

  def rating_value(ratings, source)
    match = ratings.find { |r| r["Source"] == source }
    match ? match["Value"] : ""
  end

  def url_for(title:, year: nil)
    key = ENV.fetch("OMDB_API_KEY")
    t = URI.encode_www_form_component(title)
    url = "https://www.omdbapi.com/?t=#{t}&apikey=#{key}"
    url += "&y=#{year}" if year
    url
  end
end
