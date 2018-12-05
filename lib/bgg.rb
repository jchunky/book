require_relative 'dependencies'

class Bgg
  NUMBER_OF_MONTHS = 12

  def display_game?(game)
    return true if game.ts_added.to_s > "2018-11-22"
    return false unless game.ts_added
    return false if game.players.to_h.sort.to_h.values.last(3).none? { |player_count| player_count >= 300 }
    true
  end

  def run
    @months = months_display

    @games = snake
      .merge(top_played) { |key, game1, game2| merge_ostructs(game1, game2) }
      .merge(top_ranked) { |key, game1, game2| merge_ostructs(game1, game2) }
      .values
      .tap(&method(:add_hit_date_to_games))
      .select(&method(:display_game?))
      .sort_by(&method(:rank))

    write_output
  end

  def months_display
    first = (Date.today - NUMBER_OF_MONTHS.months).beginning_of_month
    last = Date.today - 1.month
    (first..last).select { |d| d.day == 1 }
  end

  def snake
    @snake ||= Snake.new.games.map { |g| [g.key, g] }.to_h
  end

  def top_played
    @top_played ||= TopPlayed.new.games.map { |g| [g.key, g] }.to_h
  end

  def top_ranked
    @top_ranked ||= TopRanked.new.games.map { |g| [g.key, g] }.to_h
  end

  def merge_ostructs(ostruct1, ostruct2)
    OpenStruct.new(ostruct1.to_h.merge(ostruct2.to_h))
  end

  def add_hit_date_to_games(games)
    games.each(&method(:add_hit_date))
  end

  def add_hit_date(game)
    game.hit_date =
      if !game.year
        ""
      elsif game.year.to_i < Date.today.year - 1
        "#{game.year}-01-01"
      elsif game.player_count.to_i < 300 && game.ts_added
        game.ts_added
      elsif game.player_count.to_i < 300
        "#{game.year}-01-01"
      else
        month, _ = game.players.sort.find { |month, player_count| player_count >= 300 }
        month
      end
  end

  def rank(game)
    [
      game.location.blank?.to_s,
      -game.player_count.to_i,
      game.name
    ]
  end

  def write_output
    template = File.read('views/bgg.erb')
    html = ERB.new(template).result(binding)
    File.write('output/bgg.html', html)
  end
end

Bgg.new.run
