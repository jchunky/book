class Omdb
  Scores = Data.define(:rotten_tomatoes, :metacritic)

  NO_SCORES = Scores.new(rotten_tomatoes: "", metacritic: "")

  def scores(title:, year:)
    scores = scores_for(title:, year:)
    return scores unless scores == NO_SCORES

    scores_for(title:)
  end

  private

  def scores_for(title:, year: nil)
    url = url_for(title:, year:)
    CachedFile.new(url:, crawl_delay: 1).read do |content|
      parse_scores(JSON.parse(content))
    end
  rescue StandardError => e
    warn "OMDb lookup failed for '#{title}': #{e.message}"
    NO_SCORES
  end

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

  def url_for(title:, year: nil)
    key = ENV.fetch("OMDB_API_KEY")
    t = URI.encode_www_form_component(title)
    url = "http://www.omdbapi.com/?t=#{t}&apikey=#{key}"
    url += "&y=#{year}" if year
    url
  end
end
