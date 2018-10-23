require 'active_support/all'
require 'erb'
require 'net/http'
require 'nokogiri'
require 'ostruct'
require 'uri'
require_relative 'snake'
require_relative 'top_played'
require_relative 'top_ranked'
require_relative 'utils'

class Bgg2
  BLACKLIST = [
    "Analyze Me",
    "Atari's Missile Command",
    "Blackbox - Karmaka",
    "Blackbox - OrganATTACK!",
    "Blank Marry Kill",
    "Bob Ross: Happy Little Accidents",
    "Canadian Trivia: Family Edition",
    "Catan: 5-6 Player Extension",
    "Dogopoly",
    "F*THAT!",
    "Fake News",
    "Grey's Anatomy Trivia Board Game",
    "Monster Misfits",
    "Ouija",
    "Pick Your Poison: NSFW Edition",
    "Pickles to Penguins",
    "Pop Culture Trivia",
    "Q-bitz",
    "Spank the Yeti: The Adult Party Game of Questionable Decisions",
    "Stumblewood",
    "The Crow Game",
    "Who'd You Rather?",
  ]

  def run
    top_played = TopPlayed.new.games
    top_ranked = TopRanked.new.games
    snake_games = Snake.new.games

    games = top_played.map { |g| [g.key, g] }.to_h

    top_ranked.each do |game|
      if games.include?(game.key)
        game.player_count = games[game.key].player_count
      end
      games[game.key] = game
    end

    snake_games.each do |g|
      if games.include?(g.key)
        game = games[g.key]
        game.rules_url = g.rules_url
        game.difficulty = g.difficulty
        game.location = g.location
        game.categories = g.categories
      else
        games[g.key] = g
      end
    end

    @games = games
      .values
      .select { |game| display_game?(game) }

    write_output
  end

  def write_output
    template = File.read('bgg2.erb')
    html = ERB.new(template).result(binding)
    File.write('bgg2.html', html)
  end

  def display_game?(game)
    game.location &&
    game.difficulty.to_i != 3 &&
    (!game.voters.present? || (game.player_count && game.player_count.to_i >= 100)) &&
    BLACKLIST.exclude?(game.name)
  end
end

Bgg2.new.run
