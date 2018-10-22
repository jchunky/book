class Utils
  def self.generate_key(name)
    name
      .downcase
      .gsub("-", " ")
      .gsub(" and ", " & ")
      .gsub(/\bthe /, "")
      .gsub(/[^\w ]/, "")
      .gsub("(blackbox) - ", "")
      .gsub("(blackbox) ", "")
      .gsub("blackbox - ", "")
      .squish
  end
end