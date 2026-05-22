# frozen_string_literal: true

module Config
  module ProcessedTitles
    ALL = File.read("data/processed_movies.txt").split("\n").reject(&:blank?).to_set.freeze
  end
end
