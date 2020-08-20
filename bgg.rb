require "active_support/all"
require "erb"
require "json"
require "net/http"
require "nokogiri"
require "uri"
Dir["lib/*.rb"].each { |f| require_relative f }

class Bgg
  PLAY_RANK_THRESHOLD = 100
  VOTERS_THRESHOLD = 1000
  YEARS_OLD = 6
  MAX_GAME_YEAR = TopPlayed.last_year.year - YEARS_OLD
  NUMBER_OF_YEARS = TopPlayed.years_data.size

  def display_game?(game)
    return false if game[:rank].to_i < 1
    return false if game[:play_rank].to_i < 1

    # return false if game[:trend] == :down
    return false if game[:year].to_i > MAX_GAME_YEAR
    # return false if game[:play_rank].to_i > PLAY_RANK_THRESHOLD
    # return false if game[:voters].to_i < voter_threshold

    true
  end

  def run
    @bgg = self
    @months = years_display

    @games = raw_games
      .map(&method(:add_trend))
      .select(&method(:display_game?))
      .sort_by { |g| g[:play_rank].to_i }

    write_output
  end

  def player_rank(play_rank)
    calc_play_rank(play_ranks, play_rank)
  end

  def voter_rank(voters)
    calc_rank(voter_counts, voters)
  end

  private

  def add_trend(g)
    count_data = @months.map { |month| g[:play_ranks].to_h[month.to_s].to_i }
    rank_data = count_data.map(&method(:player_rank))

    g[:trend] =
      if rank_data.sort == rank_data
        :up
      elsif rank_data.last == rank_data.max
        :even
      else
        :down
      end

    g
  end

  def player_count_threshold
    @player_count_threshold ||= raw_games.map { |g| g[:player_count].to_i }.sort.reverse.take(PLAYER_COUNT_THRESHOLD).last
  end

  def voter_threshold
    @voter_threshold ||= raw_games.map { |g| g[:voters].to_i }.sort.reverse.take(VOTERS_THRESHOLD).last
  end

  def play_ranks
    @play_ranks ||= all_games.map { |g| g[:play_rank].to_i }.reject(&:zero?).sort.reverse
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
    @raw_games ||= {}
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
