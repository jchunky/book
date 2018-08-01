require 'net/http'
require 'nokogiri'
require 'ostruct'
require 'uri'

class Bgg
  def run
    url = url_for_month("2018-07-01")
    file = open_url(url)
    doc = Nokogiri::HTML(file)

    (
    doc.css('.forum_table')[1].css('tr')[1..-1].map.with_index do |row, rank|
      link, _, plays = row.css('td')
      anchor = link.css('a')
      href = anchor[0]['href']
      name = anchor[0].content
      p OpenStruct.new(href: href, name: name, rank: rank)
    end
    )
  end

  def url_for_month(month)
    "https://boardgamegeek.com/plays/bygame/start/2018-07-01/end/2018-07-31?sortby=distinctusers"
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
