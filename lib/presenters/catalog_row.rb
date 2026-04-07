# frozen_string_literal: true

module Presenters
  module CatalogRow
    def self.included(base)
      base.delegate :holds,
                    :copies,
                    :available,
                    :on_order,
                    to: :copies_info
    end

    def copies_info = catalog_item.copies_info

    def on_order
      copies_info.on_order unless copies_info.on_order.zero?
    end

    def popularity = catalog_item.popularity.score

    def popularity_class
      "number#{" low-popularity" if catalog_item.popularity.low?} popularity"
    end

    def availability_style
      copies_info.availability_style
    end

    def audience_pill
      Models::Audience.for(catalog_item).to_html
    end
  end
end
