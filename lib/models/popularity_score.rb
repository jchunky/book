# frozen_string_literal: true

module Models
  class PopularityScore < Data.define(:holds, :copies)
    LOW_THRESHOLD = 100

    def score = holds * copies
    def low? = score < LOW_THRESHOLD
    def to_i = score
  end
end
