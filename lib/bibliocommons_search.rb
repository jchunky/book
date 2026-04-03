# frozen_string_literal: true

class BibliocommonsSearch
  BASE_URL = "https://gateway.bibliocommons.com/v2" \
             "/libraries/tpl/bibs/search"

  def initialize(crawl_delay: 1, &url_builder)
    @crawl_delay = crawl_delay
    @url_builder = url_builder
  end

  def fetch_all(&bib_mapper)
    result = []
    (1..).each do |page|
      items = fetch_page(page, &bib_mapper)
      break if items.none?

      result.concat(items)
    end
    result.uniq(&:href)
  end

  private

  def fetch_page(page)
    url = @url_builder.call(page)
    CachedFile.new(url:, crawl_delay: @crawl_delay, cacheable: method(:valid_response?)).read do |content|
      data = JSON.parse(content)
      bibs = data.dig("entities", "bibs") || {}
      ids = data.dig("catalogSearch", "results")
        &.map { |r| r["representative"] } || []
      ids.filter_map { |id| yield(bibs[id]) }
    end
  rescue StandardError => e
    warn "Bibliocommons page #{page} failed: #{e.message}"
    []
  end

  def valid_response?(content)
    !JSON.parse(content).key?("error")
  rescue JSON::ParserError
    false
  end
end
