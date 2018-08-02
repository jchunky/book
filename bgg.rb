require 'active_support/all'
require 'erb'
require 'net/http'
require 'nokogiri'
require 'ostruct'
require 'uri'

class Bgg
  NUMBER_OF_MONTHS = 72

  def run
    @months = months
    @games = @months
      .map { |month| [month, url_for_month(month)] }
      .map { |month, url| [month, read_url(url)] }
      .map { |month, file| [month, Nokogiri::HTML(file)] }
      .flat_map { |month, doc| games_for_doc(month, doc) }
      .reduce({}) do |memo, game|
        memo[game.name] ||= game
        memo[game.name].ranks.merge!(game.ranks)
        memo
      end
      .select { |name, game| display_game?(game) }

    write_output
  end

  def months
    result = []
    month = (Date.today - NUMBER_OF_MONTHS.months).beginning_of_month
    while month < Date.today.beginning_of_month
      result << month
      month += 1.month
    end
    result
  end

  def url_for_month(month)
    "https://boardgamegeek.com/plays/bygame/start/#{month.beginning_of_month}/end/#{month.end_of_month}?sortby=distinctusers"
  end

  def read_url(url)
    cache(url) { open(url) }
  end

  def cache(url)
    file = "tmp/" + url.gsub(/[:\/]/, '_') + ".html"
    File.write(file, yield) unless File.exist?(file)
    File.read(file)
  end

  def open(url)
    Net::HTTP.get(URI.parse(url))
  end

  def games_for_doc(month, doc)
    doc.css('.forum_table')[1].css('tr')[1..-2].map.with_index do |row, rank|
      link, _, plays = row.css('td')
      anchor = link.css('a')
      href = anchor[0]['href']
      name = anchor[0].content

      game = OpenStruct.new(href: href, name: name, ranks: {})
      game.ranks[month.to_s] = rank + 1
      game
    end
  end

  def display_game?(game)
    game.ranks.keys.any? { |d| d >= (Date.today - 12.months).to_s } &&
      game.ranks.size >= 10
  end

  def write_output
    template = File.read('bgg.erb')
    html = ERB.new(template).result(binding)
    File.write('bgg.html', html)
  end
end

Bgg.new.run
