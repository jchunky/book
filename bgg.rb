require 'erb'
require 'net/http'
require 'nokogiri'
require 'ostruct'
require 'uri'
require 'active_support/all'

class Bgg
  def run
    @months = months
    @games = @months
      .flat_map { |month| games_for_month(month) }
      .reduce({}) do |memo, game|
        memo[game.name] ||= game
        memo[game.name].ranks.merge!(game.ranks)
        memo
      end

    write_output
  end

  def months
    result = []
    month = (Date.today - 72.months).beginning_of_month
    while month < Date.today.beginning_of_month
      result << month
      month += 1.month
    end
    result
  end

  def games_for_month(month)
    url = url_for_month(month)
    file = open_url(url)
    doc = Nokogiri::HTML(file)
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

  def url_for_month(month)
    "https://boardgamegeek.com/plays/bygame/start/#{month.beginning_of_month}/end/#{month.end_of_month}?sortby=distinctusers"
  end

  def open_url(url)
    cache(url) { open(url) }
  end

  def cache(url)
    url = "tmp/" + url.gsub(/[:\/]/, '_') + ".html"
    File.write(url, yield) unless File.exist?(url)
    File.read(url)
  end

  def open(url)
    Net::HTTP.get(URI.parse(url))
  end

  def write_output
    template = File.read('bgg.erb')
    html = ERB.new(template).result(binding)
    File.write('bgg.html', html)
  end
end

Bgg.new.run
