# frozen_string_literal: true

module Services
  class MovieFilter < SimpleDelegator
    def self.keep?(item) = new(item).keep?
    def self.to_proc = method(:keep?).to_proc

    def keep?
      return false if animation?
      return false unless certified_fresh?
      return false unless teen? || (adult? && must_see?)

      true
    end
  end
end
