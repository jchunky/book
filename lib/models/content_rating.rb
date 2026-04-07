# frozen_string_literal: true

module Models
  class ContentRating < Data.define(:name, :color)
    ALL = [
      new("G", "#16a34a"), # green
      new("PG", "#16a34a"), # green
      new("PG-13", "#ca8a04"), # amber
      new("R", "#dc2626"), # red
    ].freeze

    BY_NAME = ALL.index_by(&:name).freeze

    def self.for(name)
      BY_NAME[name]
    end

    def to_html
      %(<span style="color: #{color}; font-weight: bold;">#{name}</span>)
    end
  end
end
