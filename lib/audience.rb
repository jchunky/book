# frozen_string_literal: true

Audience = Data.define(:name, :abbr, :color) do
  ALL = [
    new("JUVENILE", "J", "#16a34a"),
    new("TEEN",     "T", "#dc2626"),
    new("ADULT",    "",  "#64748b"),
  ].freeze

  def self.for(item)
    ALL.find { item.audiences.include?(it.name) }
  end
end
