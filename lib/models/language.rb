# frozen_string_literal: true

module Models
  class Language < Data.define(:code, :name)
    ALL = [
      new("eng", ""),
      new("fre", "French"),
      new("spa", "Spanish"),
      new("ita", "Italian"),
      new("ger", "German"),
      new("jpn", "Japanese"),
      new("kor", "Korean"),
      new("chi", "Chinese"),
      new("rus", "Russian"),
      new("hin", "Hindi"),
      new("ara", "Arabic"),
      new("por", "Portuguese"),
      new("swe", "Swedish"),
      new("pol", "Polish"),
      new("heb", "Hebrew"),
      new("hun", "Hungarian"),
      new("per", "Persian"),
      new("tam", "Tamil"),
      new("dan", "Danish"),
      new("cze", "Czech"),
      new("ben", "Bengali"),
      new("tgl", "Tagalog"),
      new("pan", "Punjabi"),
      new("ukr", "Ukrainian"),
      new("tur", "Turkish"),
      new("vie", "Vietnamese"),
      new("urd", "Urdu"),
      new("zxx", "—"),
      new("mul", "Multiple"),
    ].freeze

    BY_CODE = ALL.index_by(&:code).freeze

    def self.for(code) = BY_CODE.fetch(code) { new(code, code) }

    def foreign? = code != "eng"
    def to_html = name
  end
end
