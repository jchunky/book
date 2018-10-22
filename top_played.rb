class TopPlayed
  def games
    (1..10)
      .map { |page| url_for_page(page) }
      .map { |url| read_url(url) }
      .map { |file| strip_accents(file) }
      .map { | file| Nokogiri::HTML(file) }
      .flat_map { |doc| games_for_doc(doc) }
      .uniq { |game| game.name }
  end

  def url_for_page(page)
    "https://boardgamegeek.com/plays/bygame/subtype/boardgame/start/#{month.beginning_of_month}/end/#{month.end_of_month}/page/#{page}?sortby=distinctusers"
  end

  def month
    (Date.today - 1.month).beginning_of_month
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

  def strip_accents(string)
    ActiveSupport::Inflector.transliterate(string).to_s
  end

  def games_for_doc(doc)
    doc.css('.forum_table')[1].css('tr')[1..-2].map.with_index do |row, rank|
      link, _, plays = row.css('td')
      anchor = link.css('a')
      href = anchor[0]['href']
      name = anchor[0].content
      player_count = plays.css('a')[0].content.to_i

      OpenStruct.new(
        href: href,
        name: name,
        player_count: player_count,
        key: Utils.generate_key(name)
      )
    end.compact
  end
end
