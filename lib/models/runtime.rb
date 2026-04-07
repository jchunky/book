# frozen_string_literal: true

module Models
  class Runtime < Data.define(:minutes)
    EMPTY = new(minutes: "")

    def self.parse(raw)
      value = raw.to_s
      return EMPTY if value == "N/A" || value.empty?

      new(minutes: value.delete_suffix(" min"))
    end

    def to_s = minutes
    def to_i = minutes.to_i
    def empty? = minutes.empty?
  end
end
