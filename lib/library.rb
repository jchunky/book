class Library
  BookType = Struct.new(:name, :query_fragment)
  Book = Struct.new(:title, :holds, :copies, :book_type,
                    :href, :author, :year, :rating)

  BOOK_TYPES = [
    BookType.new("MERRIL", "&f_SUBJ=Science+fiction"),
  ]

  RESULTS_PER_PAGE = 20

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
    file = Utils.read_url(url)
    doc = Nokogiri::HTML(file)
    books_for_doc(book_type, doc)
  end

  def url_for_page(book_type, page)
    base = "https://tpl.bibliocommons.com/v2/search"
    params = "?custom_edit=false"
    params += "&query=avlocation%3A%22Parkdale%22"
    params += "&searchType=bl&suppress=true"
    params += "&f_FORMAT=BK&f_CIRC=CIRC&f_PRIMARY_LANGUAGE=eng"
    params += book_type.query_fragment
    params += "&page=#{page}" if page > 1
    "#{base}#{params}"
  end

  def books_for_doc(book_type, doc)
    doc.css(".search-result-item").map do |row|
      title = row.css(".search-result-title a").first&.text.to_s.strip
      href = row.css(".search-result-title a").first&.[]("href").to_s
      author = row.css(".search-result-author a").first&.text.to_s.strip
      year = extract_year(row)
      holds, copies = extract_holds_copies(row)
      rating = holds * copies * (Date.today.year + 1 - year)

      Book.new(title, holds, copies, book_type.name,
               href, author, year, rating)
    end
  rescue StandardError
    []
  end

  def extract_year(row)
    details = row.css(".search-result-details").first&.text.to_s
    details.scan(/\d{4}/).last.to_i
  rescue StandardError
    Date.today.year
  end

  def extract_holds_copies(row)
    text = row.css(".search-result-holds").first&.text.to_s
    holds = text[/(\d+)\s*on/, 1].to_i
    copies = text[/on\s*(\d+)/, 1].to_i
    [holds, copies]
  end
end
