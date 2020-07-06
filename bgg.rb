require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "uri"
Dir["lib/*.rb"].each { |f| require_relative f }

class Bgg
  NUMBER_OF_YEARS = 12

  def display_game?(game)
    upper_year = TopPlayed.last_year.year - 5

    return false if game[:year].to_i > upper_year
    return false if game[:rank].to_i < 1
    return false if game[:rank].to_i > 300
    return false if game[:player_count].to_i < 1

    true
  end

  def run
    @games = snake

    @games = @games.merge(top_played, &method(:merge_hashes))
    @games = @games.merge(top_ranked, &method(:merge_hashes))

    @games = @games.values
      .select(&method(:display_game?))
      .sort_by { |g| -g[:player_count].to_i }

    @max_player_count = @games.map { |g| g[:players].to_h.values.max || 0 }.max
    @months = years_display

    write_output
  end

  def snake
    @snake ||= Snake.new.games.map { |g| [g[:key], g] }.to_h
  end

  def top_played
    @top_played ||= TopPlayed.new.games.map { |g| [g[:key], g] }.to_h
  end

  def top_ranked
    @top_ranked ||= TopRanked.new.games.map { |g| [g[:key], g] }.to_h
  end

  def years_display
    first = (Date.today - NUMBER_OF_YEARS.years).beginning_of_year
    last = Date.today - 1.year
    (first..last).select { |d| d.day == 1 && d.month == 1 }
  end

  def write_output
    template = File.read("views/bgg.erb")
    html = ERB.new(template).result(binding)
    File.write("index.html", html)
  end

  def merge_hashes(_key, game1, game2)
    game1.merge(game2)
  end
end

Bgg.new.run
