require 'erb'
require 'net/http'
require 'nokogiri'
require 'ostruct'
require 'uri'
require 'active_support/all'

class Bgg
  def run
    @games = {}
    @months = []
    month = (Date.today - 24.months).beginning_of_month
    while month < Date.today.beginning_of_month
      @months << month.to_s
      url = url_for_month(month)
      file = open_url(url)
      doc = Nokogiri::HTML(file)

      doc.css('.forum_table')[1].css('tr')[1..-1].map.with_index do |row, rank|
        link, _, plays = row.css('td')
        anchor = link.css('a')
        href = anchor[0]['href']
        name = anchor[0].content

        @games[name] ||= OpenStruct.new(href: href, name: name, ranks: {})

        @games[name].ranks[month.to_s] = rank + 1
      end
      month += 1.month
    end

    File.write('bgg.html', ERB.new(File.read('bgg.erb')).result(binding))
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
end

Bgg.new.run
