# frozen_string_literal: true

Genre = Data.define(:name, :color)

class Genre
  ALL = [
    new("FICTION",         "#6b7280"),
    new("MYSTERY",         "#2563eb"),
    new("ROMANCE",         "#e11d48"),
    new("SCIENCE FICTION", "#0d9488"),
    new("HORROR",          "#9333ea"),
  ].freeze

  DEFAULT_COLOR = "#444444"

  BY_NAME = ALL.index_by(&:name).freeze

  def self.for(name)
    BY_NAME.fetch(name) { new(name, DEFAULT_COLOR) }
  end
end
