# frozen_string_literal: true

module Models
  class Genre < Data.define(:name, :color)
    ALL = [
      new("FICTION", "#6b7280"), # grey
      new("MYSTERY", "#2563eb"), # blue
      new("ROMANCE", "#e11d48"), # rose
      new("SCIENCE FICTION", "#0d9488"), # teal
      new("HORROR", "#9333ea"), # purple
    ].freeze

    DEFAULT_COLOR = "#444444" # dark grey

    BY_NAME = ALL.index_by(&:name).freeze

    def self.for(name)
      BY_NAME.fetch(name) { new(name, DEFAULT_COLOR) }
    end

    def self.science_fiction?(item) = item.genre == "SCIENCE FICTION"
    def self.animation?(item) = item.genre.include?("Animation")
    def self.documentary?(item) = item.genre.include?("Documentary")
    def self.horror?(item) = item.genre.include?("Horror")
    def self.musical?(item) = item.genre.include?("Musical")
    def self.tv_series?(item) = Array(item.genre_form).any? { |g| g.match?(/television/i) }

    def to_html
      %(<span style="color: #{color}; font-weight: bold;">#{name}</span>)
    end
  end
end
