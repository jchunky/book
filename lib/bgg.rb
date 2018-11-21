require 'active_support/all'
require 'erb'
require 'net/http'
require 'nokogiri'
require 'ostruct'
require 'uri'
require_relative 'games/snake'
require_relative 'games/top_played_historical'
require_relative 'utils'

class Bgg
  NUMBER_OF_MONTHS = 72

  def display_game?(game)
    game.at_snakes
  end

  def run
    @months = months_display
    @games = TopPlayedHistorical.new.games
    snake_games = Snake.new.games.map(&:key)
    @games.each { |name, game| game.at_snakes = snake_games.include?(game.key) }
    @games = @games.select { |name, game| display_game?(game) }
    write_output
  end

  def months_display
    first = (Date.today - NUMBER_OF_MONTHS.months).beginning_of_month
    last = Date.today
    (first..last).select { |d| d.day == 1 }
  end

  def write_output
    template = File.read('views/bgg.erb')
    html = ERB.new(template).result(binding)
    File.write('output/bgg.html', html)
  end
end

Bgg.new.run
