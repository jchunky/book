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
    CHILDREN_FICTION = BookType.new("CHILDREN_FICTION", "#{CHILDREN}+38790"),
    TEEN_FICTION = BookType.new("TEEN_FICTION", "#{TEEN}+#{FICTION}"),

    ADULT_FICTION = BookType.new("ADULT_FICTION", "#{ADULT}+#{FICTION}"),
    ADULT_NON_FICTION = BookType.new("ADULT_NON_FICTION", "#{ADULT}+#{NON_FICTION}"),

    BIOGRAPHY = BookType.new("BIOGRAPHY", "#{ADULT}+4293412635"),
    CANADIAN_POETRY = BookType.new("CANADIAN_POETRY", "#{ADULT}+4293411560"),
    CHILD_REARING = BookType.new("CHILD_REARING", "#{ADULT}+4293412106"),
    CONDUCT_OF_LIFE = BookType.new("CONDUCT_OF_LIFE", "#{ADULT}+4293412367"),
    DECISION_MAKING = BookType.new("DECISION_MAKING", "#{ADULT}+4293407806"),
    DESIGN = BookType.new("DESIGN", "#{ADULT}+4293412245"),
    DRAWING = BookType.new("DRAWING", "#{ADULT}+4293412549"),
    FANTASY = BookType.new("FANTASY", "#{ADULT}+4287892397"),
    FICTION = BookType.new("FICTION", "#{ADULT}+4293412630"),
    HISTORY = BookType.new("HISTORY", "#{ADULT}+4293412643"),
    INTERPERSONAL_RELATIONS = BookType.new("INTERPERSONAL_RELATIONS", "#{ADULT}+4293412567"),
    MAN_WOMAN_RELATIONSHIPS = BookType.new("MAN_WOMAN_RELATIONSHIPS", "#{ADULT}+4293409247"),
    MYSTERY = BookType.new("MYSTERY", "#{ADULT}+37869"),
    NATURE = BookType.new("NATURE", "#{ADULT}+4293410500"),
    PERSONAL_FINANCE = BookType.new("PERSONAL_FINANCE", "#{ADULT}+4293407417"),
    PHYSICAL_FITNESS = BookType.new("PHYSICAL_FITNESS", "#{ADULT}+4293411122"),
    PLANNING = BookType.new("PLANNING", "#{ADULT}+4293410908"),
    POETRY = BookType.new("POETRY", "#{ADULT}+4293411909"),
    ROMANCE = BookType.new("ROMANCE", "#{ADULT}+37871"),
    RUBY = BookType.new("RUBY", "#{ADULT}+4293316407"),
    SCIENCE_FICTION = BookType.new("SCIENCE_FICTION", "#{ADULT}+37870"),
    SHORT = BookType.new("SHORT", "#{ADULT}+37873"),
    SOCIAL_PSYCHOLOGY = BookType.new("SOCIAL_PSYCHOLOGY", "#{ADULT}+4293406987"),
    STUDY_AND_TEACHING = BookType.new("STUDY_AND_TEACHING", "#{ADULT}+4293412474"),
    SUCCESS = BookType.new("SUCCESS", "#{ADULT}+4293408033"),
    WESTERN = BookType.new("WESTERN", "#{ADULT}+37872"),
  ]

  def books
    BOOK_TYPES.flat_map do |book_type|
      books_for(book_type)
        .sort_by { |b| -b.copies }
        .take(100)
        .select(&method(:keep?))
        .then { |books| books - graphic_books }
        .then { |books| books & past_180_days }
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
