# frozen_string_literal: true

module Models
  class Movie < Data.define(
    :biblio,
    :omdb,
  )
    delegate :title,
             :copies_info,
             :href,
             :year,
             :popularity,
             :audiences,
             :content_type,
             :genre_form,
             :jacket_url,
             :jacket_url_medium,
             :description,
             to: :biblio
    delegate :rated,
             :runtime,
             :genre,
             :box_office,
             :rotten_tomatoes,
             :metacritic,
             to: :omdb

    def self.all = Services::MovieLibrary.new.movies

    def keep? = Services::MovieFilter.keep?(self)
    def certified_fresh? = rotten_tomatoes.fresh? && !certified_fresh_excluded?
    def must_see? = metacritic.must_see? && !must_see_excluded?
    def juvenile? = Models::Audience.juvenile?(self)
    def teen? = Models::Audience.teen?(self)
    def adult? = Models::Audience.adult?(self)
    def animation? = Models::Genre.animation?(self)
    def documentary? = Models::Genre.documentary?(self)
    def horror? = Models::Genre.horror?(self)
    def musical? = Models::Genre.musical?(self)
    def tv_series? = Models::Genre.tv_series?(self)
    def restricted? = Models::ContentRating.restricted?(self)
    def display_title = omdb.title.empty? ? title : omdb.title
    def display_year = omdb.year.empty? ? year : omdb.year
    def rotten_tomatoes_url = GoogleRedirectUrl.new("site:rottentomatoes.com/m", display_title, display_year)
    def metacritic_url = GoogleRedirectUrl.new("site:metacritic.com/movie", display_title, display_year)
    def must_see_excluded? = Config::ExcludedTitles::MUST_SEE.include?(display_title)
    def certified_fresh_excluded? = Config::ExcludedTitles::CERTIFIED_FRESH.include?(display_title)
    def processed? = Config::ProcessedTitles::ALL.include?(display_title)
  end
end
