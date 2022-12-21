class Library
  BookType = Struct.new(:name, :id)
  Book = Struct.new(:title, :holds, :copies, :rating, :book_type, :href, :author)

  FICTION = "4294952052"
  NON_FICTION = "4294952073"

  CHILDREN = "37846"
  TEEN = "37845"
  ADULT = "37844"

  PAST_180_DAYS = "38755"
  GRAPHIC_BOOKS = "37874"

  GRAPHIC_BOOKS_BOOK_TYPE = BookType.new("GRAPHIC_BOOKS", GRAPHIC_BOOKS)
  PAST_180_DAYS_BOOK_TYPE = BookType.new("PAST_180_DAYS", PAST_180_DAYS)

  BOOK_TYPES = [
    BookType.new("CHILDREN_PIC", "#{PAST_180_DAYS}+38773"),
    BookType.new("CHILDREN_BR", "#{PAST_180_DAYS}+38771"),
    BookType.new("CHILDREN_ER", "#{PAST_180_DAYS}+38772"),
    BookType.new("CHILDREN_APIC", "#{PAST_180_DAYS}+38770"),
    BookType.new("CHILDREN_FICTION", "#{PAST_180_DAYS}+#{CHILDREN}+38790"),

    BookType.new("CHILDREN_DICTIONARY", "#{PAST_180_DAYS}+#{CHILDREN}+#{NON_FICTION}&Ntt=dictionary"),
    BookType.new("CHILDREN_DK", "#{PAST_180_DAYS}+#{CHILDREN}+#{NON_FICTION}&Ntt=\"dk+publishing\""),
    BookType.new("CHILDREN_ENCYCLOPEDIA", "#{PAST_180_DAYS}+#{CHILDREN}+#{NON_FICTION}&Ntt=encyclopedia"),
    BookType.new("CHILDREN_ENGLISH_LANGUAGE", "#{PAST_180_DAYS}+#{CHILDREN}+#{NON_FICTION}&Ntt=\"english+language\""),
    BookType.new("CHILDREN_HISTORY", "#{PAST_180_DAYS}+#{CHILDREN}+#{NON_FICTION}&Ntt=history"),
    BookType.new("CHILDREN_JOKES", "#{PAST_180_DAYS}+#{CHILDREN}+#{NON_FICTION}&Ntt=jokes"),
    BookType.new("CHILDREN_MATH", "#{PAST_180_DAYS}+#{CHILDREN}+#{NON_FICTION}&Ntt=mathematics"),
    BookType.new("CHILDREN_MAZE", "#{PAST_180_DAYS}+#{CHILDREN}+#{NON_FICTION}&Ntt=maze"),
    BookType.new("CHILDREN_POETRY", "#{PAST_180_DAYS}+#{CHILDREN}+#{NON_FICTION}&Ntt=poetry"),
    BookType.new("CHILDREN_PUZZLE", "#{PAST_180_DAYS}+#{CHILDREN}+#{NON_FICTION}&Ntt=puzzle"),
    BookType.new("CHILDREN_VISUAL_ENCYCLOPEDIA", "#{PAST_180_DAYS}+#{CHILDREN}+#{NON_FICTION}&Ntt=\"visual+encyclopedia\""),

    BookType.new("ART_HISTORY", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=\"art+history\""),
    BookType.new("ART_TECHNIQUE", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=\"art+technique\""),
    BookType.new("CANADIAN_POETRY", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=\"canadian+poetry\""),
    BookType.new("CHILD_REARING", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=\"child+rearing\""),
    BookType.new("CONDUCT_OF_LIFE", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=\"conduct+of+life\""),
    BookType.new("DECISION_MAKING", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=\"decision+making\""),
    BookType.new("DESIGN", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=design"),
    BookType.new("DRAWING", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=drawing"),
    BookType.new("GRAPHIC ART#{PAST_180_DAYS}+S", "#{ADULT}+#{NON_FICTION}&Ntt=\"graphic+arts\""),
    BookType.new("INTERPERSONAL_RELATIONS", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=\"interpersonal+relations\""),
    BookType.new("MAN_WOMAN_RELATIONSHIPS", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=\"man+woman+relationships\""),
    BookType.new("NATURE", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=nature"),
    BookType.new("PARENTING", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=parenting"),
    BookType.new("PERSONAL_FINANCE", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=\"personal+finance\""),
    BookType.new("PHILOSOPHY", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=philosophy"),
    BookType.new("PHYSICAL_FITNESS", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=\"physical+fitness\""),
    BookType.new("PLANNING", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=planning"),
    BookType.new("POETRY", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=poetry"),
    BookType.new("SOCIAL_PSYCHOLOGY", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=\"social+psychology\""),
    BookType.new("STUDY_AND_TEACHING", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=\"study+and+teaching\""),

    BookType.new("HISTORY", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=history"),
    BookType.new("SUCCESS", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=success"),

    ## BookType.new("BIOGRAPHY", "#{PAST_180_DAYS}+#{ADULT}+#{NON_FICTION}&Ntt=biography"),
    ## BookType.new("FANTASY", "#{PAST_180_DAYS}+#{ADULT}+#{FICTION}&Ntt=fantasy"),
    ## BookType.new("SCIENCE_FICTION", "#{PAST_180_DAYS}+#{ADULT}+#{FICTION}&Ntt=\"science+fiction\""),
    ## BookType.new("TEEN_FICTION", "#{PAST_180_DAYS}+#{TEEN}+#{FICTION}"),

    BookType.new("COMICS", "#{GRAPHIC_BOOKS}&Ntt=marvel"),
  ]

  def books
    BOOK_TYPES.flat_map do |book_type|
      books_for(book_type)
        .sort_by { |b| -b.holds }
        .select(&method(:keep?))
        # .reject { |book| graphic_books_hrefs.include?(book.href) }
        # .select { |book| past_180_days_hrefs.include?(book.href) }
    end
  end

  private

  def keep?(book)
    return false if book.holds < 10 && !(book.book_type =~ /(CHILDREN)/)
    return false if book.copies < 30 && !(book.book_type =~ /(COMICS|SUCCESS)/)

    true
  end

  def graphic_books_hrefs
    @graphic_books_hrefs ||= books_for(GRAPHIC_BOOKS_BOOK_TYPE).map(&:href)
  end

  def past_180_days_hrefs
    @past_180_days_hrefs ||= books_for(PAST_180_DAYS_BOOK_TYPE).map(&:href)
  end

  def books_for(book_type)
    result = []
    (1..).each do |page|
      books = books_for_page(book_type, page)
      break if books.none?

      result.concat(books)
    end

    result.uniq(&:href)
  end

  def books_for_page(book_type, page)
    url = url_for_page(book_type, page)
    Utils.cache_object(url) do
      file = Utils.read_url(url)
      doc = Nokogiri::HTML(file)
      books_for_doc(book_type, doc)
    end
  end

  def url_for_page(book_type, page)
    index = (page - 1) * 150
    english = "20206"
    items_that_check_out = "37751"
    regular_print_books = "37918"

    "https://www.torontopubliclibrary.ca/search.jsp?Erp=150&N=#{english}+#{items_that_check_out}+#{regular_print_books}+#{book_type.id}&No=#{index}&Ns=p_date_acquired_sort&Nso=1&Ntk=Keyword_Anywhere&view=grid"
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
  rescue StandardError
    []
  end
end
