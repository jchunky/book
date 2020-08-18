require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "uri"
Dir["lib/*.rb"].each { |f| require_relative f }

class Bgg
  PLAYER_COUNT_THRESHOLD = 100
  VOTERS_THRESHOLD = 1000
  YEARS_OLD = 6
  MAX_GAME_YEAR = TopPlayed.last_year.year - YEARS_OLD
  NUMBER_OF_YEARS = TopPlayed.years_data.size

  def display_game?(game)
    return false if game[:rank].to_i < 1
    return false if game[:player_count].to_i < 1

    # return false if game[:trend] == :down
    return false if game[:year].to_i > MAX_GAME_YEAR
    return false if game[:player_count].to_i < player_count_threshold
    return false if game[:voters].to_i < voter_threshold

    true
  end

  def run
    @bgg = self
    @months = years_display

    @games = all_games
      .map(&method(:add_trend))
      .select(&method(:display_game?))
      .sort_by { |g| -g[:player_count].to_i }

    write_output
  end

  def player_rank(player_count)
    calc_rank(player_counts, player_count)
  end

  def voter_rank(voters)
    calc_rank(voter_counts, voters)
  end

  private

  def add_trend(g)
    count_data = @months.map { |month| g[:players].to_h[month.to_s].to_i }
    rank_data = count_data.map(&method(:player_rank))

    g[:trend] =
      if count_data == count_data.sort
        :up
      elsif rank_data.last == rank_data.max
        :even
      else
        :down
      end

    g
  end

  def player_count_threshold
    @player_count_threshold ||= all_games.map { |g| g[:player_count].to_i }.sort.reverse.take(PLAYER_COUNT_THRESHOLD).last
  end

  def voter_threshold
    @voter_threshold ||= all_games.map { |g| g[:voters].to_i }.sort.reverse.take(VOTERS_THRESHOLD).last
  end

  def player_counts
    @player_counts ||= all_games.map { |g| g[:player_count].to_i }.reject(&:zero?).sort
  end

  def voter_counts
    @voter_counts ||= all_games.map { |g| g[:voters].to_i }.reject(&:zero?).sort
  end

  def calc_rank(values, value)
    i = 1
    while true
      return 6 if i == 6
      return i if value.to_i <= values[(values.size / 6.to_f * i).round - 1]
      i += 1
    end
  end

  def all_games
    @all_games ||= {}
      .merge(top_played, &method(:merge_hashes))
      .merge(top_ranked, &method(:merge_hashes))
      .values
  end

  def top_played
    @top_played ||= TopPlayed.new.games.map { |g| [g[:name], g] }.to_h
  end

  def top_ranked
    @top_ranked ||= TopRanked.new.games.map { |g| [g[:name], g] }.to_h
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
