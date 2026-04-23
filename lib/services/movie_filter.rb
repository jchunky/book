# frozen_string_literal: true

module Services
  class MovieFilter < SimpleDelegator
    def self.keep?(item) = new(item).keep?

    def keep?
      return false if animation? || documentary? || horror? || musical?
      return false unless certified_fresh?
      # return false if restricted?
      # return false unless must_see?

      true
    end
  end
end
