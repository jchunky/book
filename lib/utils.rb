module Utils
  extend self

  def read_url(url)
    strip_accents(read_url_raw(url))
  end

  private

  def strip_accents(string)
    ActiveSupport::Inflector.transliterate(string.to_s.force_encoding("UTF-8")).to_s
  end

  def read_url_raw(url)
    cache_text(url) { open(url) } # rubocop:disable Security/Open
  end

  def cache_text(id)
    file = filename(id, "html")
    return File.read(file) if File.exist?(file)

    result = yield
    File.write(file, result)
    result
  end

  def open(url)
    Net::HTTP.get(URI.parse(url))
  end

  def filename(id, extension)
    ".data/#{id.gsub(/\W/, '-')}.#{extension}"
  end
end
