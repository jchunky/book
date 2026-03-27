CatalogTitle = Data.define(:title, :subtitle) do
  def to_s
    subtitle.empty? ? title : "#{title}: #{subtitle}"
  end

  def for_search
    to_s.split(%r{ [/;] }).first.strip
  end
end
