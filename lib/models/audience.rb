# frozen_string_literal: true

module Models
  class Audience < Data.define(:name, :abbr, :color)
    ALL = [
      new("JUVENILE", "J", "#16a34a"), # green
      new("TEEN", "T", "#dc2626"), # red
      new("ADULT", "", "#64748b"), # slate
    ].freeze

    UNKNOWN = new("UNKNOWN", "", "")

    def self.for(item)
      ALL.find { item.audiences.include?(it.name) } || UNKNOWN
    end

    def self.juvenile?(item) = item.audiences.include?("JUVENILE")
    def self.teen?(item) = item.audiences.include?("TEEN")

    def self.adult?(item) = item.audiences.include?("ADULT")

    def to_html
      return "" if abbr.empty?

      %(<span style="color: #{color}; font-weight: bold;">#{abbr}</span>)
    end
  end
end
