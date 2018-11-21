class TopPlayed
  def games
    (1..10)
      .map { |page| url_for_page(page) }
      .map { |url| Utils.read_url(url) }
      .map { |file| Nokogiri::HTML(file) }
      .flat_map { |doc| games_for_doc(doc) }
      .uniq(&:key)
  end

  def url_for_page(page)
    "https://boardgamegeek.com/plays/bygame/subtype/boardgame/start/#{month.beginning_of_month}/end/#{month.end_of_month}/page/#{page}?sortby=distinctusers"
  end

  def month
    (Date.today - 1.month).beginning_of_month
  end

  def games_for_doc(doc)
    doc.css('.forum_table')[1].css('tr')[1..-1].map.with_index do |row, rank|
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
