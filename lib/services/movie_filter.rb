# frozen_string_literal: true

module Services
  class MovieFilter < SimpleDelegator
    def self.keep?(item) = new(item).keep?

    def keep?
      # == KIDS ==
      # return false unless rated?
      # return false unless box_office.to_i >= 20
      # return false unless certified_fresh?
      # return false if animation? || documentary? || horror? || musical? || juvenile?
      # return false unless display_year.to_i >= 2000
      # return false if restricted?
      # return false unless box_office.to_i >= 50

      # == DATE NIGHT ==
      # return false unless rated?
      # return false unless box_office.to_i >= 20
      # return false unless certified_fresh?
      # return false if animation? || documentary? || horror? || musical? || juvenile?
      # return false unless display_year.to_i >= 2000
      # return false unless metacritic.to_i >= 70

      # == UNPROCESSED ==
      return false unless rated?
      return false unless box_office.to_i >= 20
      return false if processed?
      return false unless must_see? || certified_fresh?

      true
    end
  end
end
