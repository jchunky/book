# frozen_string_literal: true

module Models
  class Language < Data.define(:name)
    def self.for(name) = new(name.to_s)

    def foreign? = !name.empty? && name != "English"
    def to_html = name == "English" ? "" : name
  end
end
