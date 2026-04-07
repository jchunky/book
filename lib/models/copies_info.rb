# frozen_string_literal: true

module Models
  CopiesInfo = Data.define(:copies, :available, :holds, :on_order) do
    def availability
      Availability.for(available:, copies:)
    end

    def availability_style
      availability&.style || ""
    end
  end
end
