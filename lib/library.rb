class Library
  BookType = Struct.new(:name, :id)
  Book = Struct.new(:title, :holds, :copies, :rating, :book_type, :href, :author)

  FICTION = "4294952052"
  NON_FICTION = "4294952073"

  CHILDREN = "37846"
  TEEN = "37845"
  ADULT = "37844"

  BIOGRAPHY = "4293412635"
  COOKBOOK = "4287892185"
  COMICS = "37874"
  JAPAN = "4293412397"
  PAST_180_DAYS = "38755"

  BIOGRAPHY_BOOK_TYPE = BookType.new("BIOGRAPHY", BIOGRAPHY)
  COOKBOOK_BOOK_TYPE = BookType.new("COOKBOOK", COOKBOOK)
  COMICS_BOOK_TYPE = BookType.new("COMICS", COMICS)
  JAPAN_BOOK_TYPE = BookType.new("JAPAN", JAPAN)
  PAST_180_DAYS_BOOK_TYPE = BookType.new("PAST_180_DAYS", PAST_180_DAYS)

  SUPERHEROES = "4293403305"
  PARKDALE = "33162"

  BOOK_TYPES = [
    BookType.new("CHILDREN_PARKDALE", "#{CHILDREN}+#{PARKDALE}"),
    BookType.new("NONFICTION_ADULT_PARKDALE", "#{NON_FICTION}+#{ADULT}+#{PARKDALE}"),
    BookType.new("COMICS_ADULT_PARKDALE", "#{COMICS}+#{ADULT}+#{PARKDALE}"),

    # BookType.new("CHILDREN_APIC", "38770"),
    # BookType.new("CHILDREN_BR", "38771"),
    # BookType.new("CHILDREN_ER", "38772"),
    # BookType.new("CHILDREN_FICTION", "#{CHILDREN}+38790"),
    # BookType.new("CHILDREN_PIC", "38773"),

    # BookType.new("CHILDREN_DICTIONARY", "#{CHILDREN}+#{NON_FICTION}&Ntt=dictionary"),
    # BookType.new("CHILDREN_DK", "#{CHILDREN}+#{NON_FICTION}&Ntt=\"dk+publishing\""),
    # BookType.new("CHILDREN_ENCYCLOPEDIA", "#{CHILDREN}+#{NON_FICTION}&Ntt=encyclopedia"),
    # BookType.new("CHILDREN_ENGLISH_LANGUAGE", "#{CHILDREN}+#{NON_FICTION}&Ntt=\"english+language\""),
    # BookType.new("CHILDREN_HISTORY", "#{CHILDREN}+#{NON_FICTION}&Ntt=history"),
    # BookType.new("CHILDREN_JOKES", "#{CHILDREN}+#{NON_FICTION}&Ntt=jokes"),
    # BookType.new("CHILDREN_MATH", "#{CHILDREN}+#{NON_FICTION}&Ntt=mathematics"),
    # BookType.new("CHILDREN_MAZE", "#{CHILDREN}+#{NON_FICTION}&Ntt=maze"),
    # BookType.new("CHILDREN_POETRY", "#{CHILDREN}+#{NON_FICTION}&Ntt=poetry"),
    # BookType.new("CHILDREN_PUZZLE", "#{CHILDREN}+#{NON_FICTION}&Ntt=puzzle"),
    # BookType.new("CHILDREN_VISUAL_ENCYCLOPEDIA", "#{CHILDREN}+#{NON_FICTION}&Ntt=\"visual+encyclopedia\""),

    # BookType.new("ART_HISTORY", "#{ADULT}+#{NON_FICTION}&Ntt=\"art+history\""),
    # BookType.new("ART_TECHNIQUE", "#{ADULT}+#{NON_FICTION}&Ntt=\"art+technique\""),
    # BookType.new("CANADIAN_POETRY", "#{ADULT}+#{NON_FICTION}&Ntt=\"canadian+poetry\""),
    # BookType.new("CHILD_REARING", "#{ADULT}+#{NON_FICTION}&Ntt=\"child+rearing\""),
    # BookType.new("CONDUCT_OF_LIFE", "#{ADULT}+#{NON_FICTION}&Ntt=\"conduct+of+life\""),
    # BookType.new("DECISION_MAKING", "#{ADULT}+#{NON_FICTION}&Ntt=\"decision+making\""),
    # BookType.new("DESIGN", "#{ADULT}+#{NON_FICTION}&Ntt=design"),
    # BookType.new("DRAWING", "#{ADULT}+#{NON_FICTION}&Ntt=drawing"),
    # BookType.new("GRAPHIC ARTS", "#{ADULT}+#{NON_FICTION}&Ntt=\"graphic+arts\""),
    # BookType.new("INTERPERSONAL_RELATIONS", "#{ADULT}+#{NON_FICTION}&Ntt=\"interpersonal+relations\""),
    # BookType.new("MAN_WOMAN_RELATIONSHIPS", "#{ADULT}+#{NON_FICTION}&Ntt=\"man+woman+relationships\""),
    # BookType.new("NATURE", "#{ADULT}+#{NON_FICTION}&Ntt=nature"),
    # BookType.new("PARENTING", "#{ADULT}+#{NON_FICTION}&Ntt=parenting"),
    # BookType.new("PERSONAL_FINANCE", "#{ADULT}+#{NON_FICTION}&Ntt=\"personal+finance\""),
    # BookType.new("PHILOSOPHY", "#{ADULT}+#{NON_FICTION}&Ntt=philosophy"),
    # BookType.new("PHYSICAL_FITNESS", "#{ADULT}+#{NON_FICTION}&Ntt=\"physical+fitness\""),
    # BookType.new("PLANNING", "#{ADULT}+#{NON_FICTION}&Ntt=planning"),
    # BookType.new("POETRY", "#{ADULT}+#{NON_FICTION}&Ntt=poetry"),
    # BookType.new("SOCIAL_PSYCHOLOGY", "#{ADULT}+#{NON_FICTION}&Ntt=\"social+psychology\""),
    # BookType.new("STUDY_AND_TEACHING", "#{ADULT}+#{NON_FICTION}&Ntt=\"study+and+teaching\""),

    # BookType.new("HISTORY", "#{ADULT}+#{NON_FICTION}&Ntt=history"),
    # BookType.new("SUCCESS", "#{ADULT}+#{NON_FICTION}&Ntt=success"),

    # BookType.new("COMICS", "#{COMICS}+#{SUPERHEROES}"),

    ## BookType.new("BIOGRAPHY", "#{ADULT}+#{NON_FICTION}&Ntt=biography"),
    ## BookType.new("FANTASY", "#{ADULT}+#{FICTION}&Ntt=fantasy"),
    ## BookType.new("SCIENCE_FICTION", "#{ADULT}+#{FICTION}&Ntt=\"science+fiction\""),
    ## BookType.new("TEEN_FICTION", "#{TEEN}+#{FICTION}"),
  ]

  def books
    BOOK_TYPES.flat_map do |book_type|
      books_for(book_type)
        .sort_by { |b| -b.rating }
        .select(&method(:keep?))
    end
  end

  private

  def keep?(book)
    return false if book.holds < 10
    # return false if book.rating < 100
    return false if book.rating < 1000 && book.book_type =~ /HISTORY/
    return false if book.rating < 1000 && book.book_type =~ /NONFICTION_ADULT_PARKDALE/
    return false if comics_href.include?(book.href) && !(book.book_type =~ /COMICS/)
    return false if biography_hrefs.include?(book.href) && !(book.book_type =~ /COMICS/)
    return false if cookbook_hrefs.include?(book.href) && !(book.book_type =~ /COMICS/)
    # return false if japan_hrefs.include?(book.href) && (book.book_type =~ /COMICS/)

    true
  end

  def comics_href
    @comics_href ||= books_for(COMICS_BOOK_TYPE).map(&:href)
  end

  def past_180_days_hrefs
    @past_180_days_hrefs ||= books_for(PAST_180_DAYS_BOOK_TYPE).map(&:href)
  end

  def japan_hrefs
    @japan_hrefs ||= books_for(JAPAN_BOOK_TYPE).map(&:href)
  end

  def biography_hrefs
    @biography_hrefs ||= books_for(BIOGRAPHY_BOOK_TYPE).map(&:href)
  end

  def cookbook_hrefs
    @cookbook_hrefs ||= books_for(COOKBOOK_BOOK_TYPE).map(&:href)
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

    "https://www.torontopubliclibrary.ca/search.jsp?Erp=150&N=#{PARKDALE}+#{PAST_180_DAYS}+#{english}+#{items_that_check_out}+#{regular_print_books}+#{book_type.id}&No=#{index}&view=grid"
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
