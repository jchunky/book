class TopRanked
  BookType = Struct.new(:name, :id)
  Book = Struct.new(:title, :copies, :book_type, :href, :author) do
    def display?
      # return false if book_type == "FICTION"
      return false if copies < 60

      true
    end
  end

  BOOK_TYPES = [
    PIC = BookType.new("PIC", "38773"),
    BR = BookType.new("BR", "38771"),
    ER = BookType.new("ER", "38772"),
    APIC = BookType.new("APIC", "38770"),
    CHILD = BookType.new("CHILD", "38790+37846"),
    CHILD_FICTION = BookType.new("CHILD FICTION", "4294952052+37846"),
    CHILD_NON_FICTION = BookType.new("CHILD NON-FICTION", "4294952073+37846"),
    TEEN_FICTION = BookType.new("TEEN FICTION", "4294952052+37845"),
    TEEN_NON_FICTION = BookType.new("TEEN NON-FICTION", "4294952073+37845"),
    ADULT_FICTION = BookType.new("ADULT FICTION", "4294952052+37844"),
    ADULT_NON_FICTION = BookType.new("ADULT NON-FICTION", "4294952073+37844"),
  ]

  def games
    BOOK_TYPES.flat_map do |book_type|
      (1..100)
        .lazy
        .map { |page| url_for_page(book_type, page) }
        .map { |url| Utils.read_url(url) }
        .map { |file| Nokogiri::HTML(file) }
        .flat_map { |doc| games_for_doc(book_type, doc) }
        .select(&:display?)
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
      href = row.css("a").first[:href]
      author = row.css(".p").first.content.scan(/.* author.*\./).first.to_s.strip

      Book.new(title, copies, book_type.name, href, author)
    end
  end
end
