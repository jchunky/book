# frozen_string_literal: true

require "csv"

class NytBestSellers
  NYT_DIR = File.expand_path("../../nyt-best-sellers", __dir__)

  def initialize(dir: NYT_DIR)
    @entries = load_entries(dir)
  end

  def best_seller?(title)
    @entries.key?(normalize(title.to_s))
  end

  def find(title)
    @entries[normalize(title.to_s)]
  end

  private

  def load_entries(dir)
    entries = load_csv("#{dir}/fiction.csv") +
      load_csv("#{dir}/non_fiction.csv")
    entries.to_h { |e| [normalize(e["title"]), e] }
  end

  def load_csv(path)
    CSV.read(path, headers: true).map(&:to_h)
  end

  def normalize(title)
    title.split(":").first.downcase.strip
  end
end
