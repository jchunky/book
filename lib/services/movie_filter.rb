# frozen_string_literal: true

module Services
  class MovieFilter < SimpleDelegator
    def self.keep?(item) = new(item).keep?

    def keep?
      return false if animation? || documentary? || horror? || musical?
      return false unless certified_fresh?
      return false unless rated?
      return false if juvenile?
      return false unless must_see?
      # return false unless popularity.to_i >= 100

      # return false if restricted?
      # return false unless teen?

      # return false if processed?
      # return false unless must_see? || certified_fresh?

      true
    end
  end
end
