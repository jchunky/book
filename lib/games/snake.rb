require 'json'
require_relative 'game'
require_relative 'snake_name'

class Snake < Game
  ATTRIBUTES = %w[name rules_url difficulty location category key ts_added sell_product employees_teachable]
  CATEGORIES = ["Nostalgia", "Dexterity", "Children's", "Cooperative", "Party", "Light Strategy", "Strategy", "Word", "Abstract", "Trivia", "Greatest Hits"]
  FILES = %w[abstract childrens cooperative dexterity greatest_hits light_strategy new_arrivals nostalgia party strategy trivia word].map { |f| "input/#{f}.json" }

  def self.games
    FILES
      .lazy
      .map { |f| File.read(f) }
      .map { |f| JSON.parse(f) }
      .flat_map do |rows|
        rows.map { |row_data| new(row_data).build }
      end
      .uniq(&:key)
      .force
  end

  def attributes
    ATTRIBUTES
  end

  def name
    @name ||= SnakeName.normalize(data['title'])
  end

  def rules_url
    data['rules_url']
  end

  def difficulty
    data['difficulty_label']
  end

  def location
    data['shelf_location']
  end

  def category
    game_catagories = data['categories'].map { |c| c['name'] }
    CATEGORIES.find { |c| game_catagories.include?(c) }.to_s
  end

  def key
    Utils.generate_key(name)
  end

  def ts_added
    Time.at(data['ts_added'].to_i).strftime("%Y-%m-%d")
  end

  def sell_product
    data['sell_product']
  end

  def employees_teachable
    data['employees_teachable'].size rescue 0
  end
end
