require 'active_support/all'
require 'erb'
require 'net/http'
require 'nokogiri'
require 'ostruct'
require 'uri'
require_relative 'top_played'
require_relative 'top_ranked'

class Bgg2
  def run
    top_played = TopPlayed.new.games
    top_ranked = TopRanked.new.games
    games = top_played.map { |g| [g.name, g] }.to_h

    top_ranked.each do |game|
      if games.include?(game.name)
        game.player_count = games[game.name].player_count
      end
      games[game.name] = game
    end

    @games = games.values

    write_output
  end

  def write_output
    template = File.read('bgg2.erb')
    html = ERB.new(template).result(binding)
    File.write('bgg2.html', html)
  end
end

Bgg2.new.run
