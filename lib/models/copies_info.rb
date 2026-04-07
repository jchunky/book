# frozen_string_literal: true

module Models
  class CopiesInfo < Data.define(:copies, :available, :holds, :on_order)
    def availability
      Availability.for(available:, copies:)
    end

    def availability_style
      availability&.style || ""
    end
  end
end
