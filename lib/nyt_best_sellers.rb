# frozen_string_literal: true

require "csv"
require "set"

class NytBestSellers
  NYT_DIR = File.expand_path("../../nyt-best-sellers", __dir__)

  def initialize(dir: NYT_DIR)
    @titles = load_titles(dir)
  end

  def best_seller?(title)
    @titles.include?(normalize(title.to_s))
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

  def normalize(title)
    title.split(":").first.downcase.strip
  end
end
