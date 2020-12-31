class TopRanked
  def games
    (1..10)
      .lazy
      .map { |page| url_for_page(page) }
      .map { |url| Utils.read_url(url) }
      .map { |file| Nokogiri::HTML(file) }
      .flat_map(&method(:games_for_doc))
      .force
  end

  def url_for_page(page)
    index = (page - 1) * 150
    "https://www.torontopubliclibrary.ca/search.jsp?Erp=150&N=38773+20206+37751+37918&Ne=38769&No=#{index}&Ns=p_date_acquired_sort&Nso=1&Ntk=Keyword_Anywhere&view=grid"
  end

  def games_for_doc(doc)
    doc.css(".search-results-column > .row").last.css(".details").map do |row|
      title = row.css(".ellipsis_text").first.content
      copies = row.css(".p").first.content

      Game.new(
        title: title,
        copies: copies
      )
    end
  end
end
