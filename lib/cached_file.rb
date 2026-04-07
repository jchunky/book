# frozen_string_literal: true

class CachedFile < Data.define(:url, :crawl_delay, :cacheable)
  def initialize(url:, crawl_delay:, cacheable: ->(_) { true })
    super(url:, crawl_delay:, cacheable:)
  end

  def read
    content = cache_miss? ? fetch_and_cache : File.read(file)
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
    warn "Fetching #{url}"
    Net::HTTP.get(URI.parse(url)).tap { |c| File.write(file, c) if cacheable.call(c) }
  end

  def cache_miss?
    !File.exist?(file)
  end

  def file
    ".data/#{url.gsub(/\W/, "-")}.json"
  end
end
