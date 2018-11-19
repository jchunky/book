require 'active_support/all'
require 'erb'
require 'net/http'
require 'nokogiri'
require 'ostruct'
require 'uri'
require_relative 'games/children'
require_relative 'games/snake'
require_relative 'games/top_played'
require_relative 'games/top_ranked'
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
    "Celebrity Name Game",
    "Crossfire",
    "Dogopoly",
    "Dungeon Mayhem",
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
    "Tanks, But No Thanks!",
    "The Crow Game",
    "Who'd You Rather?",
  ]

  def run
    top_played = TopPlayed.new.games
    top_ranked = TopRanked.new.games
    snake_games = Snake.new.games
    children_games = Children.new.games

    games = top_played.map { |g| [g.key, g] }.to_h

    top_ranked.each do |game|
      if games.include?(game.key)
        game.player_count = games[game.key].player_count
      end
      games[game.key] = game
    end

    children_games.each do |game|
      if games.include?(game.key)
        games[game.key].children = true
      else
        games[game.key] = game
      end
    end

    snake_games.each do |g|
      if games.include?(g.key)
        game = games[g.key]
        name = game.name
        g.to_h.each { |k, v| game[k] = v }
        game.name = name
      else
        games[g.key] = g
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

  def display_game?(game)
    BLACKLIST.exclude?(game.name) &&
    game.name != 'Unpublished Prototype' &&
    game.categories.to_s.exclude?("Nostalgia") &&
    game.categories.to_s.exclude?("Dexterity") &&
    (game.player_count.present? && game.rank.present? || game.location && game.voters.blank?)
  end
end

Bgg2.new.run
