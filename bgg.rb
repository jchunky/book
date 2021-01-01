require "active_support/all"
require "erb"
require "net/http"
require "nokogiri"
require "uri"
Dir["lib/*.rb"].each { |f| require_relative f }

class Bgg
  def display_game?(_game)
    # return false if book_type == "FICTION"
    # return false if copies < 60
    true
  end

  def run
    @games = TopRanked.new.games
      .select(&method(:display_game?))
      .sort_by { |g| [g.book_type, -g.copies, g.title] }

    p @games.count

    write_output
  end

  private

  def write_output
    template = File.read("views/bgg.erb")
    html = ERB.new(template).result(binding)
    File.write("index.html", html)
  end
end

Bgg.new.run
