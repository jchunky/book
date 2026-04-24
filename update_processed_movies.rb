# frozen_string_literal: true

require "active_support/all"
require "erb"
require "json"
require "net/http"
require "uri"

require_relative "lib/loader"
Loader.setup

class UpdateProcessedMovies
  def run
    Models::Movie.all
      .select { |m| m.rotten_tomatoes.fresh? || m.metacritic.must_see? }
      .map(&:display_title).map(&:to_s).sort.uniq
      .then do |titles|
        File.write("data/processed_movies.txt", "#{titles.join("\n")}\n")
        puts "Processed movies: #{titles.count}"
      end
  end
end

UpdateProcessedMovies.new.run
