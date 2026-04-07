# frozen_string_literal: true

module Models
  Movie = Struct.new(
    :title,
    :copies_info,
    :href,
    :year,
    :popularity,
    :audiences,
    :content_type,
    :jacket_url,
    :jacket_url_medium,
    :description,
    :omdb,
  ) do
    delegate :rated,
             :runtime,
             :genre,
             :box_office,
             :rotten_tomatoes,
             :metacritic,
             to: :omdb

    def certified_fresh? = rotten_tomatoes.to_i >= 75 && !certified_fresh_excluded?
    def must_see? = metacritic.to_i >= 80 && !must_see_excluded?
    def juvenile? = Models::Audience.juvenile?(self)
    def teen? = Models::Audience.teen?(self)
    def adult? = Models::Audience.adult?(self)
    def animation? = Models::Genre.animation?(self)
    def display_title = omdb.title.empty? ? title : omdb.title
    def display_year = omdb.year.empty? ? year : omdb.year
    def rotten_tomatoes_url = search_url("site:rottentomatoes.com/m", display_title, display_year)
    def metacritic_url = search_url("site:metacritic.com/movie", display_title, display_year)
    def must_see_excluded? = Config::ExcludedTitles::MUST_SEE.include?(display_title)
    def certified_fresh_excluded? = Config::ExcludedTitles::CERTIFIED_FRESH.include?(display_title)

    private

    def search_url(site_filter, title, year)
      query = URI.encode_www_form_component("#{site_filter} #{title} #{year}")
      "https://www.google.com/search?btnI&q=#{query}"
    end
  end
end
