class Library
  BookType = Struct.new(:name, :id)
  Book = Struct.new(:title, :holds, :copies, :rating, :book_type, :href, :author)

  FICTION = "4294952052"
  NON_FICTION = "4294952073"

  CHILDREN = "37846"
  TEEN = "37845"
  ADULT = "37844"

  PAST_180_DAYS = BookType.new("PAST_180_DAYS", "38755")
  GRAPHIC_BOOKS = BookType.new("GRAPHIC_BOOKS", "37874")

  BOOK_TYPES = [
    PIC = BookType.new("PIC", "38773"),
    BR = BookType.new("BR", "38771"),
    ER = BookType.new("ER", "38772"),
    APIC = BookType.new("APIC", "38770"),
    # CHILDREN_FICTION = BookType.new("CHILDREN_FICTION", "#{CHILDREN}+38790"),
    # TEEN_FICTION = BookType.new("TEEN_FICTION", "#{TEEN}+#{FICTION}"),

    # ADULT_FICTION = BookType.new("ADULT_FICTION", "#{ADULT}+#{FICTION}"),
    # ADULT_NON_FICTION = BookType.new("ADULT_NON_FICTION", "#{ADULT}+#{NON_FICTION}"),
    # FANTASY = BookType.new("FANTASY", "4287892397"),
    # NOVEL = BookType.new("NOVEL", "4293412630"),
    # BIOGRAPHY = BookType.new("BIOGRAPHY", "4293412635"),
    # HISTORY = BookType.new("HISTORY", "4293412643"),
    # MYSTERY = BookType.new("MYSTERY", "37869"),
    # SCIENCE_FICTION = BookType.new("SCIENCE_FICTION", "37870"),
    # ROMANCE = BookType.new("ROMANCE", "37871"),
    # WESTERN = BookType.new("WESTERN", "37872"),
    # SHORT = BookType.new("SHORT", "37873"),
  ]

  def books
    BOOK_TYPES.flat_map do |book_type|
      books_for(book_type)
        .reject { |book| book.copies < 10 }
        .reject { |book| book.title.include?("Captain Underpants") }
        .reject { |book| book.title.include?("Christmas") }
        .reject { |book| book.title.include?("Claus") }
        .reject { |book| book.title.include?("Santa") }
        .reject { |book| graphic_books_hrefs.include?(book.href) }
        .reject { |book| past_180_days_hrefs.include?(book.href) }
        .sort_by { |b| [b.book_type, -b.holds] }
        .take(100)
    end
  end

  private

  def past_180_days_hrefs
    @past_180_days_hrefs ||= books_for(PAST_180_DAYS).map(&:href).force
  end

  def graphic_books_hrefs
    @graphic_books_hrefs ||= books_for(GRAPHIC_BOOKS).map(&:href).force
  end

  def books_for(book_type)
    (1..130)
      .lazy
      .map { |page| url_for_page(book_type, page) }
      .map { |url| Utils.read_url(url) }
      .map { |file| Nokogiri::HTML(file) }
      .flat_map { |doc| books_for_doc(book_type, doc) }
      .uniq(&:href)
  end

  def url_for_page(book_type, page)
    index = (page - 1) * 150

    "https://www.torontopubliclibrary.ca/search.jsp?Erp=150&N=20206+37751+37918+#{book_type.id}&No=#{index}&Ns=p_date_acquired_sort&Nso=1&Ntk=Keyword_Anywhere&view=grid"
  end

  def books_for_doc(book_type, doc)
    doc.css(".search-results-column > .row").last.css(".details").map do |row|
      title = row.css(".ellipsis_text").first.content
      holds = row.css(".p").first.content.scan(/\d+ hold/).first.to_i
      copies = row.css(".p").first.content.scan(/\d+ cop/).first.to_i
      rating = holds * copies
      href = row.css("a").first[:href]
      author = row.css(".p").first.content.scan(/.* author.*\./).first.to_s.strip

      Book.new(title, holds, copies, rating, book_type.name, href, author)
    end
  end
end
