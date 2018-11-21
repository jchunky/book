require 'active_support/all'
require 'erb'
require 'net/http'
require 'nokogiri'
require 'ostruct'
require 'uri'
require_relative 'games/snake'
require_relative 'games/top_played'
require_relative 'games/top_ranked'
require_relative 'utils'

class Bgg2
  def display_game?(game)
    return false unless game.location
    return true if game.ts_added > "2018-11-17"
    return false if game.categories.include?("Nostalgia")
    return false if game.categories.include?("Dexterity")
    return false if game.categories.include?("Greatest Hits")
    return false if game.player_count.to_i < 100
    return false if game.rank.to_i >= 1000
    true
  end

  def run
    snake_games = Snake.new.games
    top_played = TopPlayed.new.games
    top_ranked = TopRanked.new.games

    games = snake_games.map { |g| [g.key, g] }.to_h

    top_ranked.each do |g|
      if games.include?(g.key)
        game = games[g.key]
        g.to_h.each { |k, v| game[k] = v }
      end
    end

    top_played.each do |g|
      if games.include?(g.key)
        game = games[g.key]
        g.to_h.each { |k, v| game[k] = v }
      end
    end

    @games = games
      .values
      .select { |game| display_game?(game) }
      .sort_by { |g| [g.location.blank?.to_s, -g.player_count.to_i, g.name] }

    write_output
  end

  def write_output
    template = File.read('views/bgg2.erb')
    html = ERB.new(template).result(binding)
    File.write('output/bgg2.html', html)
  end
end

Bgg2.new.run
