class Library
  BookType = Struct.new(:name, :id)
  Book = Struct.new(:title, :holds, :copies, :book_type, :href, :author, :year, :rating)

  FICTION = "4294952052"
  NON_FICTION = "4294952073"

  CHILDREN = "37846"
  TEEN = "37845"
  ADULT = "37844"

  BOOK_TYPES = [
    BookType.new("CHILDREN", "#{CHILDREN}"),
    BookType.new("CHILDREN_APIC", "38770"),
    BookType.new("CHILDREN_BR", "38771"),
    BookType.new("CHILDREN_ER", "38772"),
    BookType.new("CHILDREN_FICTION", "#{CHILDREN}+38790"),
    BookType.new("CHILDREN_PIC", "38773"),
    # BookType.new("TEEN_FICTION", "#{TEEN}+#{FICTION}"),

    BookType.new("BIOGRAPHY", "#{ADULT}+#{NON_FICTION}&Ntt=biography"),
    BookType.new("COMICS", "#{ADULT}+37874"),
    BookType.new("HISTORY", "#{ADULT}+#{NON_FICTION}&Ntt=history"),
    BookType.new("NONFICTION", "#{ADULT}+#{NON_FICTION}"),
    BookType.new("SCIENCE_FICTION", "#{ADULT}+#{FICTION}+37870"),
    BookType.new("SHORT_STORIES", "#{ADULT}+#{FICTION}+37873"),
    BookType.new("SUCCESS", "#{ADULT}+#{NON_FICTION}&Ntt=success"),
  ]

  def books
    BOOK_TYPES.flat_map do |book_type|
      books_for(book_type)
        .select(&method(:keep?))
        .sort_by { |b| -b.rating }
        .first(30)
    end
  end

  private

  def keep?(book)
    # return false if book.holds < 100
    # return false if book.copies < 10
    # return false if (book.year >= Date.today.year - 5)
    return false if book.year == 0

    true
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
    "https://www.torontopubliclibrary.ca/search.jsp?Erp=150&N=#{common_criteria}+#{book_type.id}&No=#{index}&view=grid"
  end

  def common_criteria
    [
      english = "20206",
      items_that_check_out = "37751",
      parkdale = "33162",
      # past_180_days = "38755",
      regular_print_books = "37918",
    ].join("+")
  end

  def books_for_doc(book_type, doc)
    doc.css(".search-results-column > .row").last.css(".details").map do |row|
      title = row.css(".ellipsis_text").first.content
      holds = row.css(".p").first.content.scan(/\d+ hold/).first.to_i
      copies = row.css(".p").first.content.scan(/\d+ cop/).first.to_i
      href = row.css("a").first[:href]
      author = row.css(".p").first.content.scan(/.* author.*\./).first.to_s.strip
      year = (row.css('.date').first.content.to_i rescue 0)
      rating = holds * copies * (Date.today.year + 1 - year)

      Book.new(title, holds, copies, book_type.name, href, author, year, rating)
    end
  rescue StandardError
    []
  end
end
