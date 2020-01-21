require_relative 'dependencies'

class Bgg
  NUMBER_OF_MONTHS = 12

  def display_game?(game)
    return true if game[:ts_added].to_s > "2020-01-16"
    return false unless game[:subdomain]
    return false unless game[:ts_added]
    # return false if game[:rank].to_i > 300
    return false if game[:rank].to_i < 1
    # return false if game[:player_count].to_i < 300
    return false if game[:player_count].to_i < 1
    true
  end

  def run
    @games = snake
      .merge(top_played) { |key, game1, game2| game1.merge(game2) }
      .merge(top_ranked) { |key, game1, game2| game1.merge(game2) }
      .merge(top_family) { |key, game1, game2| game1.merge(game2) }
      .merge(top_party) { |key, game1, game2| game1.merge(game2) }
      .values
      .select(&method(:display_game?))
      .sort_by { |g| -g[:player_count].to_i }

    @max_player_count = @games.map { |g| g[:players].to_h.values.max || 0 }.max
    @months = months_display

    write_output
  end

  def months_display
    first = (Date.today - NUMBER_OF_MONTHS.months).beginning_of_month
    last = Date.today - 1.month
    (first..last).select { |d| d.day == 1 }
  end

  def snake
    @snake ||= Snake.new.games.map { |g| [g[:key], g] }.to_h
  end

  def top_party
    @top_party ||= TopParty.new.games.map { |g| [g[:key], g] }.to_h
  end

  def top_played
    @top_played ||= TopPlayed.new.games.map { |g| [g[:key], g] }.to_h
  end

  def top_ranked
    @top_ranked ||= TopRanked.new.games.map { |g| [g[:key], g] }.to_h
  end

  def top_family
    @top_family ||= TopFamily.new.games.map { |g| [g[:key], g] }.to_h
  end

  def write_output
    template = File.read('views/bgg.erb')
    html = ERB.new(template).result(binding)
    File.write('output/bgg.html', html)
  end
end

Bgg.new.run
