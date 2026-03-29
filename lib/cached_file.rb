# frozen_string_literal: true

class CachedFile < Data.define(:url, :crawl_delay)
  def read
    content = cache_expired? ? fetch_and_cache : File.read(file)
    yield(content)
  end

  def read_if_cached
    return unless File.exist?(file)

    yield(File.read(file))
  end

  def invalidate
    FileUtils.rm_f(file)
  end

  private

  def fetch_and_cache
    sleep crawl_delay
    print "."
    Net::HTTP.get(URI.parse(url)).tap { |c| File.write(file, c) }
  end

  def cache_expired?
    !File.exist?(file)
  end

  def file
    ".data/#{url.gsub(/\W/, "-")}.json"
  end
end
