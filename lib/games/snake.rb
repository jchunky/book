require 'json'
require_relative 'snake_name'

class Snake
  CATEGORIES = ["Nostalgia", "Dexterity", "Children's", "Cooperative", "Party", "Light Strategy", "Strategy", "Word", "Abstract", "Trivia", "Greatest Hits"]
  FILES = %w[abstract childrens cooperative dexterity greatest_hits light_strategy new_arrivals nostalgia party strategy trivia word].map { |f| "input/#{f}.json" }

  def games
    FILES
      .lazy
      .map { |f| File.read(f) }
      .map { |f| JSON.parse(f) }
      .flat_map do |rows|
        rows.map(&method(:build_game))
      end
      .uniq(&:key)
      .force
  end

  def build_game(data)
    name = SnakeName.normalize(data['title'])

    OpenStruct.new(
      name: name,
      key: Utils.generate_key(name),
      rules_url: data['rules_url'],
      difficulty: data['difficulty_label'],
      location: data['shelf_location'],
      ts_added: Time.at(data['ts_added'].to_i).strftime("%Y-%m-%d"),
      sell_product: data['sell_product'],
      employees_teachable: (data['employees_teachable'].size rescue 0),
      category: category(data)
    )
  end

  def category(data)
    game_catagories = data['categories'].map { |c| c['name'] }
    CATEGORIES.find { |c| game_catagories.include?(c) }.to_s
  end
end