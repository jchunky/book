# frozen_string_literal: true

module Services
  class MovieFilter < SimpleDelegator
    def self.keep?(item) = new(item).keep?

    def keep?
      # return false if animation? || documentary? || horror? || musical? || juvenile?
      # return false unless box_office.to_i >= 10
      # return false unless certified_fresh?
      # return false unless display_year.to_i >= 1985
      # return false unless rated?

      # == KIDS ==
      # return false if restricted?

      # == ME ==
      # return false unless must_see?
      # return false unless display_year.to_i >= 2015

      # == UNPROCESSED ==
      return false if processed?
      return false unless must_see? || certified_fresh?

      true
    end
  end
end
