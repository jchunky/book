class Omdb
  Scores = Data.define(:rotten_tomatoes, :metacritic)

  NO_SCORES = Scores.new(rotten_tomatoes: "", metacritic: "")

  def scores(title:, year:)
    url = url_for(title:, year:)
    CachedFile.new(url:, crawl_delay: 1).read do |content|
      parse_scores(JSON.parse(content))
    end
  rescue StandardError
    NO_SCORES
  end

  private

  def parse_scores(data)
    return NO_SCORES unless data["Response"] == "True"

    ratings = Array(data["Ratings"])
    Scores.new(
      rotten_tomatoes: rating_value(ratings, "Rotten Tomatoes"),
      metacritic: rating_value(ratings, "Metacritic")
    )
  end

  def rating_value(ratings, source)
    match = ratings.find { |r| r["Source"] == source }
    match ? match["Value"] : ""
  end

  def url_for(title:, year:)
    key = ENV.fetch("OMDB_API_KEY")
    t = URI.encode_www_form_component(title)
    "https://www.omdbapi.com/?apikey=#{key}&t=#{t}&y=#{year}"
  end
end
