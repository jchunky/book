module Utils
  extend self

  CRAWL_DELAY = 2

  def read_url(url)
    strip_accents(read_url_raw(url))
  end

  private

  def strip_accents(string)
    ActiveSupport::Inflector.transliterate(string.to_s.force_encoding("UTF-8")).to_s
  end

  def read_url_raw(url)
    cache_text(url) { fetch(url) }
  end

  def cache_text(id)
    file = filename(id, "json")
    return File.read(file) if File.exist?(file)

    result = yield
    File.write(file, result)
    result
  end

  def fetch(url)
    respect_crawl_delay
    print "."
    Net::HTTP.get(URI.parse(url))
  end

  def respect_crawl_delay
    return unless @last_fetch_at

    elapsed = Time.now - @last_fetch_at
    sleep(CRAWL_DELAY - elapsed) if elapsed < CRAWL_DELAY
  ensure
    @last_fetch_at = Time.now
  end

  def filename(id, extension)
    ".data/#{id.gsub(/\W/, '-')}.#{extension}"
  end
end
