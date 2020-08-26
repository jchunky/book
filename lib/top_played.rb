class TopPlayed
  def self.years_data
    first = Date.parse("2005-01-01")
    last = last_year

    (first..last)
      .select { |d| d.day == 1  && d.month == 1 }
  end

  def self.last_year
    (Date.today - 1.year).beginning_of_year
  end

  def games
    self.class.years_data.product((1..10).to_a)
      .lazy
      .map { |month, page| [month, page, url_for_year_and_page(month, page)] }
      .map { |month, page, url| [month, page, Utils.read_url(url)] }
      .map { |month, page, file| [month, page, Nokogiri::HTML(file)] }
      .flat_map { |month, page, doc| games_for_doc(month, page, doc) }
      .force
      .each_with_object({}) do |game, memo|
        memo[game.name] ||= game
        memo[game.name] = memo[game.name].merge(game)
      end
      .values
  end

  def url_for_year_and_page(year, page)
    start_date = year.beginning_of_year
    end_date = year.end_of_year
    end_date -= 1.day if year.year == 2019

    "https://boardgamegeek.com/plays/bygame/subtype/All/start/#{start_date}/end/#{end_date}/page/#{page}?sortby=distinctusers&subtype=All"
  end

  def games_for_doc(month, page, doc)
    doc.css(".forum_table")[1].css("tr").drop(1).map.with_index do |row, i|
      link, _, plays = row.css("td")
      anchor = link.css("a")
      name = Utils.strip_accents(anchor[0].content)
      play_count = plays.css("a")[0].content.to_i
      play_rank = (page - 1) * 100 + i + 1

      game = Game.new(
        href: anchor[0]["href"],
        name: name,
        key: Utils.generate_key(name)
      )
      game.add_player_count(month, play_count, play_rank)
      game
    end
  rescue
    []
  end
end
