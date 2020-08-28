require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "uri"
Dir["lib/*.rb"].each { |f| require_relative f }

class Bgg
  PLAY_RANK_THRESHOLD = 100
  YEARS_OLD = 6
  MAX_GAME_YEAR = TopPlayed.last_year.year - YEARS_OLD

  def display_game?(game)
    return true if game.ts_added > "2020-03-12"
    return false if game.rank < 1
    return false if game.play_rank < 1

    return false unless game.in_top_100_in_last_two_years?
    # return false unless game.ts_added.present?
    # return false if game.play_rank > PLAY_RANK_THRESHOLD
    # return false if game.year > MAX_GAME_YEAR
    # return false unless game.was_in_top_100?

    true
  end

  def run
    @bgg = self
    @months = TopPlayed.years_data

    @games = raw_games
      .select(&method(:display_game?))
      .sort_by { |g| [-g.year, g.play_rank] }

    write_output
  end

  def player_rank(play_rank)
    calc_play_rank(play_ranks, play_rank)
  end

  def voter_rank(voters)
    calc_rank(voter_counts, voters)
  end

  private

  def play_ranks
    @play_ranks ||= all_games.map { |g| g.play_rank }.reject(&:zero?).sort.reverse
  end

  def voter_counts
    @voter_counts ||= all_games.map { |g| g.voters }.reject(&:zero?).sort
  end

  def calc_rank(values, value)
    i = 1
    while true
      return 6 if i == 6
      return i if value.to_i <= values[(values.size / 6.to_f * i).round - 1]
      i += 1
    end
  end

  def calc_play_rank(values, value)
    i = 1
    while true
      return 1 if value.to_i == 0
      return 6 if i == 6
      return i if value.to_i >= values[(values.size / 6.to_f * i).round - 1]
      i += 1
    end
  end

  def all_games
    @all_games ||= raw_games
  end

  def raw_games
    @raw_games ||= top_ranked
      .merge(top_played, &method(:merge_hashes))
      .merge(snake, &method(:merge_hashes))
      .values
  end

  def top_ranked
    @top_ranked ||= TopRanked.new.games.map { |g| [g.key, g] }.to_h
  end

  def top_played
    @top_played ||= TopPlayed.new.games.map { |g| [g.key, g] }.to_h
  end

  def snake
    @snake ||= Snake.new.games.map { |g| [g.key, g] }.to_h
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
