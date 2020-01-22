class Snake
  FILES = Dir.glob("input/**/*.json").to_a
  CATEGORIES = [
    "Cooperative",
    "Party",
    "Light Strategy",
    "Strategy",

    "Nostalgia",
    "Deck Builder",
    "Children's",
    "Dexterity",
    "Word",
    "Trivia",
    "Abstract",

    "Greatest Hits",
    "New Arrivals"
  ]

  def games
    FILES
      .lazy
      .map { |f| [f, File.read(f)] }
      .map { |f, file| [f, JSON.parse(file)] }
      .flat_map do |f, rows|
        rows.map { |row| build_game(f, row) }
      end
      .force
      .sort_by(&method(:sort_order))
      .uniq { |g| g[:key] }
  end

  def sort_order(game)
    [shelf_priority(game[:shelf]), location_priority(game[:location])]
  end

  def shelf_priority(shelf)
    shelf == "Archives" ? 2 : 1
  end

  def location_priority(location)
    case location
    when "Annex"
      2
    when "College"
      1
    when "Midtown"
      3
    else
      0
    end
  end

  def build_game(f, data)
    name = SnakeName.normalize(Utils.strip_accents(data['title']))

    {
      name: name,
      key: Utils.generate_key(name),
      rules_url: data['rules_url'],
      difficulty: data['difficulty_label'],
      ts_added: Time.at(data['ts_added'].to_i).strftime("%Y-%m-%d"),
      sell_product: data['sell_product'],
      employees_teachable: (data['employees_teachable'].size rescue 0),
      category: category(data),
      location: location(f),
      shelf: shelf(data)
    }
  end

  def category(data)
    data['categories']
      .map { |c| c['name'] }
      .sort_by { |c| CATEGORIES.index(c).to_i }
      .map { |c| c.delete(" ") }
      .join(" ")
  end

  def location(file)
    file.split('/')[1].capitalize
  end

  def shelf(data)
    data['shelf_location']
  end
end