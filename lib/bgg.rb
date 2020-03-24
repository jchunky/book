require_relative 'dependencies'

class Bgg
  NUMBER_OF_MONTHS = 12

  SUBDOMAINS = {
    "family" => 5499,
    "party" => 5498,
    "strategy" => 5497,
    "thematic" => 5496,
    "customizable" => 4667,
    "abstract" => 4666,
    "childrens" => 4665,
    "war" => 4664,
  }

  def display_game?(game)
    return true if game[:ts_added].to_s > "2020-03-23"
    return false unless game[:ts_added]
    return false unless game[:location] == "College"
    # return false unless (%w[family party] & game[:subdomains].to_a).any?
    return false if game[:shelf] == "Archives"
    return false if game[:rank].to_i < 1
    return false if game[:player_count].to_i < 1
    true
  end

  def run
    @games = snake

    @games = @games.merge(top_played, &method(:merge_hashes))
    @games = @games.merge(top_ranked, &method(:merge_hashes))

    SUBDOMAINS.each do |subdomain_name, subdomain_id|
      @games = @games.merge(subdomain(subdomain_name, subdomain_id), &method(:merge_subdomains))
    end

    @games = @games.values
      .select(&method(:display_game?))
      .sort_by { |g| -g[:player_count].to_i }

    @max_player_count = @games.map { |g| g[:players].to_h.values.max || 0 }.max
    @months = months_display

    write_output
  end

  def snake
    @snake ||= Snake.new.games.map { |g| [g[:key], g] }.to_h
  end

  def top_played
    @top_played ||= TopPlayed.new.games.map { |g| [g[:key], g] }.to_h
  end

  def top_ranked
    @top_ranked ||= TopRanked.new.games.map { |g| [g[:key], g] }.to_h
  end

  def subdomain(subdomain_name, subdomain_id)
    Subdomain.new(subdomain_name, subdomain_id).games.map { |g| [g[:key], g] }.to_h
  end

  def months_display
    first = (Date.today - NUMBER_OF_MONTHS.months).beginning_of_month
    last = Date.today - 1.month
    (first..last).select { |d| d.day == 1 }
  end

  def write_output
    template = File.read('views/bgg.erb')
    html = ERB.new(template).result(binding)
    File.write('output/bgg.html', html)
  end

  def merge_hashes(key, game1, game2)
    game1.merge(game2)
  end

  def merge_subdomains(key, game1, game2)
    game1.merge(subdomains: game1[:subdomains].to_a + game2[:subdomains].to_a)
  end
end

Bgg.new.run
