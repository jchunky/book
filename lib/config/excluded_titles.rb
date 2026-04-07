# frozen_string_literal: true

require "yaml"

module Config
  module ExcludedTitles
    CERTIFIED_FRESH = YAML.load_file("data/excluded_certified_fresh.yml").to_set.freeze
    MUST_SEE = YAML.load_file("data/excluded_must_see.yml").to_set.freeze
  end
end
