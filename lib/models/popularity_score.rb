# frozen_string_literal: true

module Models
  PopularityScore = Data.define(:holds, :copies)

  class PopularityScore
    LOW_THRESHOLD = 100

    def score = holds * copies
    def low? = score < LOW_THRESHOLD
    def to_i = score
  end
end
