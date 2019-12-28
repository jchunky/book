class Snake
  FILES = Dir.glob("input/**/*.json").to_a
  CATEGORIES = [
    "Trivia",
    "Children's",
    "Word",
    "Party",
    "Dexterity",
    "Nostalgia",

    "Cooperative",
    "Deck Builder",
    "Light Strategy",
    "Strategy",

    "Abstract",

    "Greatist Hits",
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
      .uniq { |g| g[:key] }
      .force
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
      location: location(f),
      category: category(data),
      shelf: shelf(data)
    }
  end

  def location(file)
    file.split('/')[1].capitalize
  end

  def category(data)
    data['categories']
      .map { |c| c['name'] }
      .sort_by { |c| CATEGORIES.index(c).to_i }
      .first
      .to_s
  end

  def shelf(data)
    # location = data['shelf_location']
    # location = location.gsub("Archives, ", "").gsub(", Archives", "").gsub(", Sickbay", "").strip
    # location.size == 2 ? "0" + location : location
    data['shelf_location']
  end
end