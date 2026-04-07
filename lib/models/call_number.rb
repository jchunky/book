# frozen_string_literal: true

module Models
  class CallNumber < Data.define(:raw)
    def genre
      if raw.match?(/\A\d/)
        Dewey.lookup(raw)
      else
        raw.split[0..-2].join(" ")
      end
    end
  end
end
