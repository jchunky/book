class CachedFile < Data.define(:url, :crawl_delay)
  CACHE_EXPIRY = 1.year

  def read
    content = cache_expired? ? fetch_from_url : File.read(file)
    result = yield(content)
    File.write(file, content) if cache_expired?
    result
  end

  private

  def fetch_from_url
    sleep crawl_delay
    print "."
    # puts url
    Net::HTTP.get(URI.parse(url))
  end

  def cache_expired?
    !File.exist?(file) || File.mtime(file) < (Time.now - CACHE_EXPIRY)
  end

  def file
    ".data/#{url.gsub(/\W/, "-")}.json"
  end
end
