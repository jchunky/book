CatalogTitle = Data.define(:title, :subtitle) do
  def to_s
    raw = subtitle.empty? ? title : "#{title}: #{subtitle}"
    raw.split(%r{ [/;=] }).first.strip
  end
end
