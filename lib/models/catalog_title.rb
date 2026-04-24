# frozen_string_literal: true

module Models
  class CatalogTitle < Data.define(:title, :subtitle)
    def to_s
      raw = subtitle.empty? ? title : "#{title}: #{subtitle}"
      raw.split(%r{ [/;=] }).first.to_s.strip
    end
  end
end
