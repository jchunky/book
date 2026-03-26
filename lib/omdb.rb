class Omdb
  RateLimitError = Class.new(StandardError)

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
  rescue RateLimitError
    raise
  rescue StandardError => e
    warn "OMDb lookup failed for '#{title}': #{e.message}"
    NO_INFO
  end

  def parse_info(data)
    if data["Error"]&.include?("limit")
      raise RateLimitError, data["Error"]
    end
    return NO_INFO unless data["Response"] == "True"

    ratings = Array(data["Ratings"])
    Info.new(
      year: data["Year"].to_s,
      rated: clean_value(data["Rated"]),
      runtime: clean_value(data["Runtime"]),
      genre: data["Genre"].to_s,
      box_office: round_to_million(data["BoxOffice"]),
      rotten_tomatoes: rating_value(ratings, "Rotten Tomatoes"),
      metacritic: clean_value(rating_value(ratings, "Metacritic"))
    )
  end

  def round_to_million(value)
    amount = value.to_s.gsub(/\D/, "").to_i
    return "" if amount.zero?

    "$#{(amount / 1_000_000.0).round}M"
  end

  def clean_value(value)
    value = value.to_s
    value == "N/A" ? "" : value.delete_suffix(" min").delete_suffix("/100")
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
