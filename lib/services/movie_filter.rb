# frozen_string_literal: true

module Services
  class MovieFilter < SimpleDelegator
    def self.keep?(item) = new(item).keep?

    def keep?
      # return false if animation? || documentary? || horror? || musical?
      # return false unless certified_fresh?
      # return false if restricted?
      # return false if juvenile?
      # return false unless teen?
      # return false unless must_see?
      return false if tv_series?
      return false if processed?
      return false unless must_see? || certified_fresh?

      true
    end
  end
end
