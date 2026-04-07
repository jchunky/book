# frozen_string_literal: true

Audience = Data.define(:name, :abbr, :color)

class Audience
  ALL = [
    new("JUVENILE", "J", "#16a34a"), # green
    new("TEEN",     "T", "#dc2626"), # red
    new("ADULT",    "",  "#64748b"), # slate
  ].freeze

  def self.for(item)
    ALL.find { item.audiences.include?(it.name) }
  end
end
