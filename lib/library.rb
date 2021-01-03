class Library
  BookType = Struct.new(:name, :id)
  Book = Struct.new(:title, :holds, :copies, :rating, :book_type, :href, :author) do
    def ==(other)
      href == other
    end

    def eql?(other)
      href == other.href
    end

    def hash
      href.hash
    end
  end

  FICTION = "4294952052"
  NON_FICTION = "4294952073"

  CHILDREN = "37846"
  TEEN = "37845"
  ADULT = "37844"

  GRAPHIC_BOOKS = BookType.new("GRAPHIC_BOOKS", "37874")
  PAST_180_DAYS = BookType.new("PAST_180_DAYS", "38755")

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
        .sort_by { |b| -b.copies }
        .take(100)
        .select(&method(:keep?))
        .then { |books| books - graphic_books }
    end
  end

  private

  def keep?(book)
    return false if book.title =~ /avengers/i
    return false if book.title =~ /bad guys/i
    return false if book.title =~ /batman/i
    return false if book.title =~ /captain america/i
    return false if book.title =~ /captain underpants/i
    return false if book.title =~ /christmas/i
    return false if book.title =~ /claus/i
    return false if book.title =~ /disney/i
    return false if book.title =~ /dog man/i
    return false if book.title =~ /fly guy/i
    return false if book.title =~ /halloween/i
    return false if book.title =~ /iron man/i
    return false if book.title =~ /peppa pig/i
    return false if book.title =~ /santa/i
    return false if book.title =~ /spider-man/i
    return false if book.title =~ /wolverine/i
    return false if book.title =~ /x-men/i

    true
  end

  def graphic_books
    @graphic_books ||= books_for(GRAPHIC_BOOKS)
  end

  def past_180_days
    @past_180_days ||= books_for(PAST_180_DAYS)
  end

  def books_for(book_type)
    result = []
    (1..).each do |page|
      books = books_for_page(book_type, page)
      break if books.none?

      result.concat(books)
    end

    result.reject { |book| book.copies < 30 }.uniq
  end

  def books_for_page(book_type, page)
    url = url_for_page(book_type, page)
    file = Utils.read_url(url)
    doc = Nokogiri::HTML(file)
    books_for_doc(book_type, doc)
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
