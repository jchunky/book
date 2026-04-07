# frozen_string_literal: true

class MovieFilter
  def call(movie)
    return false if movie.animation?
    return false unless movie.certified_fresh?
    return false unless movie.teen? || (movie.adult? && movie.must_see?)

    true
  end

  def to_proc = method(:call).to_proc
end
