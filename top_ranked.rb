class TopRanked
  def games
    (1..200)
      .map { |page| url_for_page(page) }
      .map { |url| read_url(url) }
      .map { |file| strip_accents(file) }
      .map { | file| Nokogiri::HTML(file) }
      .flat_map { |doc| games_for_doc(doc) }
      .uniq { |game| game.name }
  end

  def url_for_page(page)
    "https://boardgamegeek.com/browse/boardgame/page/#{page}"
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
    doc.css('.collection_table')[0].css('tr')[1..-1].map.with_index do |row, rank|
      rank, _, title, _, rating, voters = row.css('td')

      rank = rank.css('a')[0]['name'] rescue nil
      href = title.css('a')[0]['href']
      name = title.css('a')[0].content
      rating = rating.content
      voters = voters.content

      OpenStruct.new(
        href: href,
        name: name,
        rank: rank,
        rating: rating,
        voters: voters,
        key: Utils.generate_key(name)
      )
    end.compact
  end
end
