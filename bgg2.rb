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
    # @games = TopPlayed.new.games
    @games = TopRanked.new.games

    write_output
  end

  def write_output
    template = File.read('bgg2.erb')
    html = ERB.new(template).result(binding)
    File.write('bgg2.html', html)
  end
end

Bgg2.new.run
