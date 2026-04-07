# frozen_string_literal: true

module Models
  class GoogleRedirectUrl < Data.define(:site_filter, :title, :year)
    def to_s
      query = URI.encode_www_form_component("#{site_filter} #{title} #{year}")
      "https://www.google.com/search?btnI&q=#{query}"
    end
  end
end
