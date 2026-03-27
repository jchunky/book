class CachedFile < Data.define(:url, :crawl_delay)
  CACHE_EXPIRY = 1.year

  def read
    content = cache_expired? ? fetch_and_cache : File.read(file)
    yield(content)
  end

  def invalidate
    File.delete(file) if File.exist?(file)
  end

  private

  def fetch_and_cache
    sleep crawl_delay
    print "."
    Net::HTTP.get(URI.parse(url)).tap { |c| File.write(file, c) }
  end

  def cache_expired?
    !File.exist?(file) || File.mtime(file) < (Time.now - CACHE_EXPIRY)
  end

  def file
    ".data/#{url.gsub(/\W/, "-")}.json"
  end
end
