class TopPlayedHistorical
  def games
    months_data
      .lazy
      .map { |month| [month, url_for_month(month)] }
      .map { |month, url| [month, Utils.read_url(url)] }
      .map { |month, file| [month, Nokogiri::HTML(file)] }
      .flat_map { |month, doc| games_for_doc(month, doc) }
      .force
      .each_with_object({}) do |game, memo|
        memo[game.name] ||= game
        memo[game.name].ranks.merge!(game.ranks)
        memo[game.name].players.merge!(game.players)
      end
      .values
  end

  def months_data
    first = Date.parse('2005-01-01')
    last = Date.today - 1.month
    (first..last).select { |d| d.day == 1 }
  end

  def url_for_month(month)
    "https://boardgamegeek.com/plays/bygame/start/#{month.beginning_of_month}/end/#{month.end_of_month}?sortby=distinctusers"
  end

  def games_for_doc(month, doc)
    doc.css('.forum_table')[1].css('tr')[1..-2].map.with_index do |row, rank|
      link, _, plays = row.css('td')
      anchor = link.css('a')
      href = anchor[0]['href']
      name = anchor[0].content
      key = Utils.generate_key(name)
      play_count = plays.css('a')[0].content.to_i

      next if play_count < 1

      game = OpenStruct.new(href: href, name: name, key: key, ranks: {}, players: {})
      game.ranks[month.to_s] = rank + 1
      game.players[month.to_s] = play_count
      game
    end.compact.uniq(&:key)
  end
end
