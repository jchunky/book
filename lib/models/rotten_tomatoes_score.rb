# frozen_string_literal: true

module Models
  class RottenTomatoesScore < Data.define(:value)
    FRESH_THRESHOLD = 75
    EMPTY = new(value: "")

    def self.parse(raw)
      cleaned = raw.to_s
      return EMPTY if cleaned == "N/A" || cleaned.empty?

      new(value: cleaned.delete_suffix("%"))
    end

    def fresh? = to_i >= FRESH_THRESHOLD
    def to_s = value
    def to_i = value.to_i
    def empty? = value.empty?
  end
end
