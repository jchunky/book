require_relative 'dependencies'

class Bgg2
  def run
    @games = Snake.new.games
      .tap { |games| merge_games(games, top_played) }
      .tap { |games| merge_games(games, top_ranked) }
      .select(&method(:display_game?))
      .sort_by(&method(:rank))

    write_output
  end

  def display_game?(game)
    return false unless game.location
    return true if game.ts_added > "2018-11-17"
    return false if game.category == "Dexterity"
    return false if game.category == "Nostalgia"
    return false if game.player_count.to_i < 100
    return false if game.year.to_i < 1980
    true
  end

  def rank(game)
    [
      game.location.blank?.to_s,
      -game.player_count.to_i,
      game.name
    ]
  end

  def write_output
    template = File.read('views/bgg2.erb')
    html = ERB.new(template).result(binding)
    File.write('output/bgg2.html', html)
  end

  def top_played
    @top_played ||= TopPlayed.new.games.map { |g| [g.key, g] }.to_h
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

Bgg2.new.run
