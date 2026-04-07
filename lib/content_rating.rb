# frozen_string_literal: true

ContentRating = Data.define(:name, :color)

class ContentRating
  ALL = [
    new("G",     "#16a34a"),
    new("PG",    "#16a34a"),
    new("PG-13", "#ca8a04"),
    new("R",     "#dc2626"),
  ].freeze

  BY_NAME = ALL.index_by(&:name).freeze

  def self.for(name)
    BY_NAME[name]
  end
end
