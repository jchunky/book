# frozen_string_literal: true

module Models
  class MetacriticScore < Data.define(:value)
    MUST_SEE_THRESHOLD = 80
    EMPTY = new(value: "")

    def self.parse(raw)
      cleaned = raw.to_s
      return EMPTY if cleaned == "N/A" || cleaned.empty?

      new(value: cleaned.delete_suffix("/100"))
    end

    def must_see? = to_i >= MUST_SEE_THRESHOLD
    def to_s = value
    def to_i = value.to_i
    def empty? = value.empty?
  end
end
