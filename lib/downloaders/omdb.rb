# frozen_string_literal: true

module Downloaders
  class Omdb
    class RateLimitError < StandardError
    end

    class Info < Data.define(
      :title,
      :year,
      :rated,
      :runtime,
      :genre,
      :box_office,
      :rotten_tomatoes,
      :metacritic,
    )
    end

    NO_INFO = Info.new(
      title: "",
      year: "",
      rated: "",
      runtime: Models::Runtime::EMPTY,
      genre: "",
      box_office: Models::BoxOffice::EMPTY,
      rotten_tomatoes: Models::RottenTomatoesScore::EMPTY,
      metacritic: Models::MetacriticScore::EMPTY,
    )

    def info(title:, year:)
      titles = [title]
      base = title.split(":").first.strip
      titles << base if base != title

      titles.each do |t|
        result = info_for(title: t, year:)
        return result if result != NO_INFO && titles_match?(t, result.title)

        result = info_for(title: t)
        return result unless result == NO_INFO
      end

      NO_INFO
    end

    private

    def titles_match?(requested, returned)
      requested.downcase == returned.downcase
    end

    def info_for(title:, year: nil)
      cached = Utils::CachedFile.new(
        url: url_for(title:, year:),
        crawl_delay: 1,
        cacheable: method(:cacheable_response?),
      )
      return cached_info(cached) if @rate_limited

      cached.read { |content| parse_info(JSON.parse(content)) }
    rescue RateLimitError
      cached.invalidate
      @rate_limited = true
      warn "OMDb daily limit reached, using cache only"
      NO_INFO
    rescue StandardError => e
      warn "OMDb lookup failed for '#{title}': #{e.message}"
      NO_INFO
    end

    def cached_info(cached)
      cached.read_if_cached { |c| parse_info(JSON.parse(c)) } || NO_INFO
    rescue StandardError
      NO_INFO
    end

    def parse_info(data)
      raise(RateLimitError, data["Error"]) if data["Error"]&.include?("limit")
      return NO_INFO unless data["Response"] == "True"

      ratings = Array(data["Ratings"])
      Info.new(
        title: data["Title"].to_s,
        year: data["Year"].to_s,
        rated: clean_value(data["Rated"]),
        runtime: Models::Runtime.parse(data["Runtime"]),
        genre: data["Genre"].to_s,
        box_office: Models::BoxOffice.parse(data["BoxOffice"]),
        rotten_tomatoes: Models::RottenTomatoesScore.parse(rating_value(ratings, "Rotten Tomatoes")),
        metacritic: Models::MetacriticScore.parse(rating_value(ratings, "Metacritic")),
      )
    end

    def clean_value(value)
      value = value.to_s
      value == "N/A" ? "" : value
    end

    def rating_value(ratings, source)
      match = ratings.find { |r| r["Source"] == source }
      match ? match["Value"] : ""
    end

    def cacheable_response?(content)
      data = JSON.parse(content)
      data["Response"] == "True" || data["Error"]&.include?("not found")
    rescue JSON::ParserError
      false
    end

    def url_for(title:, year: nil)
      key = ENV.fetch("OMDB_API_KEY")
      t = URI.encode_www_form_component(title)
      url = "https://www.omdbapi.com/?t=#{t}&apikey=#{key}"
      url += "&y=#{year}" if year
      url
    end
  end
end
