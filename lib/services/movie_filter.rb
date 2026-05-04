# frozen_string_literal: true

module Services
  class MovieFilter < SimpleDelegator
    def self.keep?(item) = new(item).keep?

    def keep?
      # return false if animation? || documentary? || horror? || musical? || juvenile?
      return false unless rated?
      return false unless box_office.to_i >= 20
      return false unless rotten_tomatoes.to_i >= 75
      # return false unless display_year.to_i >= 2000

      # == KIDS ==
      # return false if restricted?
      # return false unless box_office.to_i >= 50

      # == DATA NIGHT ==
      # return false unless metacritic.to_i >= 70

      # == UNPROCESSED ==
      return false if processed?
      return false unless must_see? || certified_fresh?

      true
    end
  end
end
