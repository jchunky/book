# frozen_string_literal: true

module Services
  class MovieFilter < SimpleDelegator
    def self.keep?(item) = new(item).keep?

    def keep?
      return false if animation? || musical? || juvenile?

      # return false unless omdb_matched?
      # return false unless omdb_unmatched?
      # return false unless omdb_unqueried?

      return false unless omdb.movie?
      return false unless rated?
      return false unless box_office.to_i >= 1
      return false unless metacritic.to_i >= 1
      return false unless rotten_tomatoes.to_i >= 1

      # return false unless watched?
      # return false unless loved?
      # return false if restricted?
      return false if processed?
      # return false unless foreign?

      # return false unless display_year.to_i >= 2000
      # return false unless metacritic.to_i >= 70
      # return false unless popularity.to_i >= 1

      true
    end
  end
end
