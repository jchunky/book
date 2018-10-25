class Children
  def games
    (1..8)
      .map { |page| url_for_page(page) }
      .map { |url| Utils.read_url(url) }
      .map { |file| Nokogiri::HTML(file) }
      .flat_map { |doc| games_for_doc(doc) }
      .uniq { |game| game.name }
  end

  def url_for_page(page)
    "https://boardgamegeek.com/childrensgames/browse/boardgame/page/#{page}"
  end

  def games_for_doc(doc)
    doc.css('.collection_table')[0].css('tr')[1..-1].map do |row|
      _, _, title, *_ = row.css('td')

      href = title.css('a')[0]['href']
      name = title.css('a')[0].content

      OpenStruct.new(
        href: href,
        name: name,
        key: Utils.generate_key(name),
        children: true
      )
    end.compact
  end
end
