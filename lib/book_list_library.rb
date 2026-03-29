# frozen_string_literal: true

class BookListLibrary
  BookListEntry = Data.define(
    :title, :call_number, :dewey_class, :dewey_division, :href,
  )

  def entries
    titles.filter_map { |title| search(title) }
  end

  private

  def titles
    File.readlines("input/book-list.txt", chomp: true).reject(&:empty?)
  end

  def search(title)
    CachedFile.new(url: url_for(title), crawl_delay: 1).read do |content|
      bib_to_entry(title, first_bib(JSON.parse(content)))
    end
  rescue StandardError
    nil
  end

  def url_for(title)
    query = URI.encode_www_form_component("title:(#{title})")
    "#{BibliocommonsSearch::BASE_URL}?query=#{query}" \
      "&searchType=smart&f_FORMAT=BK"
  end

  def first_bib(data)
    bibs = data.dig("entities", "bibs") || {}
    id = data.dig("catalogSearch", "results", 0, "representative")
    bibs[id]
  end

  def bib_to_entry(search_title, bib)
    return unless bib

    cn = bib.dig("briefInfo", "callNumber").to_s
    BookListEntry.new(
      title: search_title, call_number: cn,
      dewey_class: Dewey.class_lookup(cn),
      dewey_division: Dewey.lookup(cn),
      href: "/v2/record/#{bib["id"]}",
    )
  end
end
