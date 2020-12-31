class TopRanked
  Book = Struct.new(:title, :copies, :book_type)
  BookType = Struct.new(:name, :id)

  BOOK_TYPES = [
    PIC = BookType.new("PIC", "38773&Ne=38769"),
    BR = BookType.new("BR", "38771&Ne=38769"),
    ER = BookType.new("ER", "38772&Ne=38769"),
    APIC = BookType.new("APIC", "38770&Ne=38769"),
    FICTION = BookType.new("FICTION", "38790+37846&Ne=27605"),
  ]

  def games
    BOOK_TYPES.flat_map do |book_type|
      (1..100)
        .lazy
        .map { |page| url_for_page(book_type, page) }
        .map { |url| Utils.read_url(url) }
        .map { |file| Nokogiri::HTML(file) }
        .flat_map { |doc| games_for_doc(book_type, doc) }
        .force
    end
  end

  def url_for_page(book_type, page)
    index = (page - 1) * 150

    "https://www.torontopubliclibrary.ca/search.jsp?Erp=150&N=20206+37751+37918+#{book_type.id}&No=#{index}&Ns=p_date_acquired_sort&Nso=1&Ntk=Keyword_Anywhere&view=grid"
  end

  def games_for_doc(book_type, doc)
    doc.css(".search-results-column > .row").last.css(".details").map do |row|
      title = row.css(".ellipsis_text").first.content
      copies = row.css(".p").first.content.scan(/\d+ copies/).first.to_i

      Book.new(title, copies, book_type.name)
    end
  end
end
