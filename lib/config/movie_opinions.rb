# frozen_string_literal: true

module Config
  module MovieOpinions
    LOVED = File.read("data/loved_movies.txt").split("\n").reject(&:blank?).to_set.freeze
    DISLIKED = File.read("data/disliked_movies.txt").split("\n").reject(&:blank?).to_set.freeze
  end
end
