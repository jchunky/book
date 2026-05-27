# frozen_string_literal: true

module Downloaders
  class Omdb
    class RateLimitError < StandardError
    end

    class Info < Data.define(
      :title,
      :year,
      :type,
      :rated,
      :runtime,
      :genre,
      :box_office,
      :rotten_tomatoes,
      :metacritic,
      :primary_language,
      :director,
      :country,
    )
      def movie? = type == "movie"
      def series? = type == "series"
      def episode? = type == "episode"
      def game? = type == "game"
    end

    NO_INFO = Info.new(
      title: "",
      year: "",
      type: "",
      rated: "",
      runtime: Models::Runtime::EMPTY,
      genre: "",
      box_office: Models::BoxOffice::EMPTY,
      rotten_tomatoes: Models::RottenTomatoesScore::EMPTY,
      metacritic: Models::MetacriticScore::EMPTY,
      primary_language: "",
      director: "",
      country: "",
    )

    class Lookup < Data.define(:info, :status)
      def matched?   = status == :matched
      def unmatched? = status == :unmatched
      def unqueried? = status == :unqueried
    end

    UNQUERIED = Lookup.new(info: NO_INFO, status: :unqueried)

    def lookup(title:, year:)
      titles = [title]
      base = title.split(":").first.to_s.strip
      titles << base if base != title

      best = UNQUERIED
      titles.each do |t|
        if year.to_i >= 1
          result = lookup_for(title: t, year:)
          return result if result.matched? && titles_match?(t, result.info.title)
          best = prefer(best, result)
        end

        result = lookup_for(title: t)
        return result if result.matched?
        best = prefer(best, result)
      end

      best
    end

    private

    def prefer(current, candidate)
      return candidate if current.unqueried? && !candidate.unqueried?
      current
    end

    def titles_match?(requested, returned)
      requested.downcase == returned.downcase
    end

    def lookup_for(title:, year: nil)
      cached = Utils::CachedFile.new(
        url: url_for(title:, year:),
        crawl_delay: 1,
        cacheable: method(:cacheable_response?),
      )
      return cached_lookup(cached) if @rate_limited

      info = cached.read { |content| parse_info(JSON.parse(content)) }
      lookup_from(info)
    rescue RateLimitError
      cached.invalidate
      @rate_limited = true
      warn "OMDb daily limit reached, using cache only"
      UNQUERIED
    rescue StandardError => e
      warn "OMDb lookup failed for '#{title}': #{e.message}"
      UNQUERIED
    end

    def cached_lookup(cached)
      info = cached.read_if_cached { |c| parse_info(JSON.parse(c)) }
      return UNQUERIED unless info

      lookup_from(info)
    rescue StandardError
      UNQUERIED
    end

    def lookup_from(info)
      status = info == NO_INFO ? :unmatched : :matched
      Lookup.new(info:, status:)
    end

    def parse_info(data)
      raise(RateLimitError, data["Error"]) if data["Error"]&.include?("limit")
      return NO_INFO unless data["Response"] == "True"

      ratings = Array(data["Ratings"])
      Info.new(
        title: data["Title"].to_s,
        year: data["Year"].to_s,
        type: data["Type"].to_s,
        rated: clean_value(data["Rated"]),
        runtime: Models::Runtime.parse(data["Runtime"]),
        genre: data["Genre"].to_s,
        box_office: Models::BoxOffice.parse(data["BoxOffice"]),
        rotten_tomatoes: Models::RottenTomatoesScore.parse(rating_value(ratings, "Rotten Tomatoes")),
        metacritic: Models::MetacriticScore.parse(rating_value(ratings, "Metacritic")),
        primary_language: primary_language(data["Language"]),
        director: primary_director(data["Director"]),
        country: primary_country(data["Country"]),
      )
    end

    def clean_value(value)
      value = value.to_s
      value == "N/A" ? "" : value
    end

    def primary_language(value)
      cleaned = clean_value(value)
      return "" if cleaned == "None"

      cleaned.split(",").first.to_s.strip
    end

    def primary_country(value)
      clean_value(value).split(",").first.to_s.strip
    end

    def primary_director(value)
      clean_value(value).split(",").first.to_s.strip
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
