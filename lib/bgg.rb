require_relative 'dependencies'

class Bgg
  NUMBER_OF_MONTHS = 72

  def run
    @months = months_display

    @games = Snake.new.games
      .tap { |games| merge_games(games, top_played) }
      .tap { |games| merge_games(games, top_ranked) }
      .select(&method(:display_game?))
      .sort_by(&method(:rank))

    write_output
  end

  def display_game?(game)
    game.location && game.ranks
  end

  def rank(game)
    if game.year.to_i <= 2005
      [game.year, game.ranks.keys.min]
    else
      [game.ranks.keys.min]
    end
  end

  def months_display
    first = (Date.today - NUMBER_OF_MONTHS.months).beginning_of_month
    last = Date.today - 1.month
    (first..last).select { |d| d.day == 1 }
  end

  def write_output
    template = File.read('views/bgg.erb')
    html = ERB.new(template).result(binding)
    File.write('output/bgg.html', html)
  end

  def top_played
    @top_played ||= TopPlayedHistorical.new.games.map { |g| [g.key, g] }.to_h
  end

  def top_ranked
    @top_ranked ||= TopRanked.new.games.map { |g| [g.key, g] }.to_h
  end

  def merge_games(games1, games2)
    games1.each { |g| merge_ostructs(g, games2[g.key]) }
  end

  def merge_ostructs(ostruct1, ostruct2)
    ostruct2.to_h.each { |k, v| ostruct1[k] = v }
  end
end

Bgg.new.run