# frozen_string_literal: true

require "csv"
require "set"

class NytBestSellers
  NYT_DIR = File.expand_path("../../nyt-best-sellers", __dir__)

  def initialize(dir: NYT_DIR)
    @titles = load_titles(dir)
  end

  def best_seller?(title)
    norm = normalize(title.to_s)
    exact?(norm) || substring?(norm)
  end

  private

  def load_titles(dir)
    titles = load_csv("#{dir}/fiction.csv") +
      load_csv("#{dir}/non_fiction.csv")
    Set.new(titles.map { |t| normalize(t) })
  end

  def load_csv(path)
    CSV.read(path, headers: true).map { |r| r["title"] }
  end

  def exact?(norm)
    @titles.include?(norm)
  end

  def substring?(norm)
    return false if norm.length < 8

    @titles.any? { |t| t.start_with?(norm) || norm.start_with?(t) }
  end

  def normalize(title)
    title.downcase.gsub(/[^a-z0-9\s]/, "").gsub(/\s+/, " ").strip
  end
end
