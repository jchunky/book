# frozen_string_literal: true

Availability = Data.define(:name, :text_color, :bg_color)

class Availability
  NONE = new("avail-none", "#991b1b", "#fee2e2") # red
  LOW  = new("avail-low",  "#9a3412", "#fff7ed") # orange
  OK   = new("avail-ok",   "#166534", "#dcfce7") # green

  def self.for(available:, copies:)
    return NONE if available.zero?
    return LOW if copies.positive? && available <= copies / 4
    OK if available.positive?
  end
end
