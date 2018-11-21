require 'active_support/all'
require 'erb'
require 'net/http'
require 'nokogiri'
require 'ostruct'
require 'uri'
require_relative 'games/snake'
require_relative 'games/top_played_historical'
require_relative 'games/top_ranked'
require_relative 'utils'

class Bgg
  NUMBER_OF_MONTHS = 72

  def display_game?(game)
    game.at_snakes
  end

  def run
    top_ranked = TopRanked.new.games.map { |g| [g.key, g] }.to_h
    @months = months_display
    @games = TopPlayedHistorical.new.games
    snake_games = Snake.new.games.map(&:key)
    @games.each { |name, game| game.at_snakes = snake_games.include?(game.key) }
    @games = @games.select { |name, game| display_game?(game) }
    @games.each { |name, game| game.year = top_ranked[game.key]&.year }
    @games = @games.sort_by do |name, game|
      if game.year.to_i <= 2005
        [game.year, game.ranks.keys.min]
      else
        [game.ranks.keys.min]
      end
    end.to_h
    write_output
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
end

Bgg.new.run
