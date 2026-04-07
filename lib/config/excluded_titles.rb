# frozen_string_literal: true

module Config
  module ExcludedTitles
    def self.read(filename) = File.read("data/#{filename}").split("\n").reject(&:blank?).to_set.freeze

    CERTIFIED_FRESH = read("excluded_certified_fresh.txt")
    MUST_SEE = read("excluded_must_see.txt")
  end
end
