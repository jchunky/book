class Snake
  FILES = Dir.glob("input/*.json").to_a
  SMALL_BOX_LOCATIONS = %w[01C 02C 06C 07D 10C 11A 13C 15C 20B 20C 20D 21B 21E 22D 29B 29C 29D]
  SHELF_CATEGORIES = {
    (1..2) => "Trivia",
    (3..4) => "Children",
    (5..6) => "Nostalgia",
    (7..7) => "Word",
    (8..11) => "Party",
    (12..13) => "Dexterity",
    (14..16) => "Abstract",
    (20..22) => "Small Games",
    (23..28) => "Light Strategy",
    (29..29) => "Bluffing",
    (30..31) => "Co-op",
    (32..32) => "Deck Builder",
    (33..36) => "Strategy",
  }

  def games
    FILES
      .lazy
      .map { |f| File.read(f) }
      .map { |f| JSON.parse(f) }
      .flat_map do |rows|
        rows.map(&method(:build_game))
      end
      .uniq { |g| g[:key] }
      .force
  end

  def build_game(data)
    name = SnakeName.normalize(Utils.strip_accents(data['title']))

    {
      name: name,
      key: Utils.generate_key(name),
      rules_url: data['rules_url'],
      difficulty: data['difficulty_label'],
      location: location(data),
      ts_added: Time.at(data['ts_added'].to_i).strftime("%Y-%m-%d"),
      sell_product: data['sell_product'],
      employees_teachable: (data['employees_teachable'].size rescue 0),
      small_box: small_box(data),
      category: category(location(data))
    }
  end

  def category(location)
    _, result = SHELF_CATEGORIES.find { |k, v| k.include?(location.to_i) }
    result || location
  end

  def location(data)
    location = data['shelf_location']
    location = location.gsub("Archives, ", "").gsub(", Archives", "").gsub(", Sickbay", "").strip
    location.size == 2 ? "0" + location : location
  end

  def small_box(data)
    SMALL_BOX_LOCATIONS.include?(location(data))
  end
end