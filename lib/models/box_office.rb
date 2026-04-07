# frozen_string_literal: true

module Models
  class BoxOffice < Data.define(:millions)
    EMPTY = new(millions: "")

    def self.parse(raw)
      amount = raw.to_s.gsub(/\D/, "").to_i
      return EMPTY if amount.zero?

      new(millions: (amount / 1_000_000.0).round.to_s)
    end

    def to_s = millions
    def to_i = millions.to_i
    def empty? = millions.empty?
  end
end
