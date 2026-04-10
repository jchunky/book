# frozen_string_literal: true

module Services
  class MovieFilter < SimpleDelegator
    def self.keep?(item) = new(item).keep?

    def keep?
      return false if animation? || horror?
      return false unless certified_fresh?
      # return false unless teen?
      # return false unless must_see?
      # return false unless !(teen? || (adult? && must_see?))

      true
    end
  end
end
