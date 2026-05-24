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
             :primary_language,
             :director,
             :country,
             to: :omdb

    def self.all = Services::MovieLibrary.new.movies

    def keep? = Services::MovieFilter.keep?(self)
    def certified_fresh? = rotten_tomatoes.fresh?
    def must_see? = metacritic.must_see?
    def juvenile? = Models::Audience.juvenile?(self)
    def teen? = Models::Audience.teen?(self)
    def adult? = Models::Audience.adult?(self)
    def animation? = Models::Genre.animation?(self)
    def documentary? = Models::Genre.documentary?(self)
    def action? = Models::Genre.action?(self)
    def comedy? = Models::Genre.comedy?(self)
    def horror? = Models::Genre.horror?(self)
    def musical? = Models::Genre.musical?(self)
    def tv_series? = Models::Genre.tv_series?(self)
    def restricted? = Models::ContentRating.restricted?(self)
    def foreign? = Models::Language.for(primary_language).foreign?
    def rated? = Models::ContentRating.rated?(self)
    def display_title = omdb.title.empty? ? title : omdb.title
    def display_year = omdb.year.empty? ? year.to_i : omdb.year.to_i
    def rotten_tomatoes_url = GoogleRedirectUrl.new("site:rottentomatoes.com/m", display_title, display_year)
    def metacritic_url = GoogleRedirectUrl.new("site:metacritic.com/movie", display_title, display_year)
    def processed? = Config::ProcessedTitles::ALL.include?(display_title)
    def loved? = Config::MovieOpinions::LOVED.include?(display_title)
    def disliked? = Config::MovieOpinions::DISLIKED.include?(display_title)
  end
end
