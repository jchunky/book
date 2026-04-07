# frozen_string_literal: true

module Models
  CallNumber = Data.define(:raw) do
    def genre
      if raw.match?(/\A\d/)
        Dewey.lookup(raw)
      else
        raw.split[0..-2].join(" ")
      end
    end
  end
end
