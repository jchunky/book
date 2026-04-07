# frozen_string_literal: true

module Models
  Audience = Data.define(:name, :abbr, :color)

  class Audience
    ALL = [
      new("JUVENILE", "J", "#16a34a"), # green
      new("TEEN", "T", "#dc2626"), # red
      new("ADULT", "", "#64748b"), # slate
    ].freeze

    def self.for(item)
      ALL.find { item.audiences.include?(it.name) }
    end

    def self.juvenile?(item) = item.audiences.include?("JUVENILE")
    def self.teen?(item) = item.audiences.include?("TEEN")
    def self.adult?(item) = item.audiences.include?("ADULT")
  end
end
