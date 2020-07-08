class TopPlayed
  NUMBER_OF_YEARS = 15

  def games
    years_data.product((1..1).to_a)
      .lazy
      .map { |month, page| [month, url_for_year_and_page(month, page)] }
      .map { |month, url| [month, Utils.read_url(url)] }
      .map { |month, file| [month, Nokogiri::HTML(file)] }
      .flat_map { |month, doc| games_for_doc(month, doc) }
      .force
      .each_with_object({}) do |game, memo|
        memo[game[:name]] ||= game
        memo[game[:name]][:players] = game[:players].merge(memo[game[:name]][:players])
      end
      .values
      .tap { |games| add_player_count(games) }
  end

  def years_data
    first = Date.parse("2005-01-01")
    last = self.class.last_year

    (first..last)
      .select { |d| d.day == 1  && d.month == 1}
      .last(NUMBER_OF_YEARS)
  end

  def url_for_year_and_page(year, page)
    start_date = year.beginning_of_year
    end_date = year.end_of_year - 1.day

    "https://boardgamegeek.com/plays/bygame/subtype/All/start/#{start_date}/end/#{end_date}/page/#{page}?sortby=distinctusers&subtype=All"
  end

  def games_for_doc(month, doc)
    doc.css(".forum_table")[1].css("tr").drop(1).map do |row|
      link, _, plays = row.css("td")
      anchor = link.css("a")
      name = Utils.strip_accents(anchor[0].content)
      play_count = plays.css("a")[0].content.to_i

      game = {
        href: anchor[0]["href"],
        name: name,
        key: Utils.generate_key(name),
        players: {},
      }
      game[:players][month.to_s] = play_count
      game
    end
  rescue
    []
  end

  def add_player_count(games)
    games.each do |game|
      game[:player_count] = game[:players].to_h[self.class.last_year.to_s].to_i
    end
  end

  def self.last_year
    (Date.today - 1.year).beginning_of_year
  end
end
