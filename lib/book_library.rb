class BookLibrary
  BookType = Struct.new(:name, :query_fragment)
  Book = Struct.new(:title, :holds, :copies, :book_type,
                    :href, :author, :year, :rating,
                    :availability_status, :audiences,
                    :content_type, :genre, :subject,
                    :available)

  BOOK_TYPES = [
    BookType.new("ALL", ""),
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
    # return false if book.year == 0

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
    CachedFile.new(url:, crawl_delay: 1).read do |content|
      data = JSON.parse(content)
      bibs = data.dig("entities", "bibs") || {}
      ids = data.dig("catalogSearch", "results")
        &.map { |r| r["representative"] } || []
      ids.filter_map { |id| bib_to_book(book_type, bibs[id]) }
    end
  rescue StandardError
    []
  end

  def url_for_page(book_type, page)
    base = "https://gateway.bibliocommons.com/v2"
    base += "/libraries/tpl/bibs/search"
    params = "?query=avlocation%3A%22Parkdale%22"
    params += "&searchType=bl&suppress=true"
    params += "&f_FORMAT=BK&f_CIRC=CIRC&f_PRIMARY_LANGUAGE=eng"
    params += book_type.query_fragment
    params += "&page=#{page}" if page > 1
    "#{base}#{params}"
  end

  def bib_to_book(book_type, bib)
    return unless bib

    info = bib["briefInfo"] || {}
    avail = bib["availability"] || {}

    title = info["title"].to_s
    author = Array(info["authors"]).first.to_s
    year = info["publicationDate"].to_i
    holds = avail["heldCopies"].to_i
    copies = avail["totalCopies"].to_i
    href = "/v2/record/#{bib["id"]}"
    rating = holds * copies #* (Date.today.year + 1 - year)

    Book.new(title, holds, copies, book_type.name,
             href, author, year, rating,
             avail["localisedStatus"].to_s,
             Array(info["audiences"]).join(", "),
             info["contentType"].to_s,
             Array(info["genreForm"]).join(", "),
             Array(info["subjectHeadings"]).join(", "),
             avail["availableCopies"].to_i)
  end
end
