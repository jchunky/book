# frozen_string_literal: true

module Services
  class MovieFilter < SimpleDelegator
    def self.keep?(item) = new(item).keep?

    def keep?
      # == KIDS ==
      return false unless meet_minimum_quality_bar?
      return false unless meet_personal_interest_criteria?
      return false if restricted?
      return false unless box_office.to_i >= 50

      # == DATE NIGHT ==
      # return false unless meet_minimum_quality_bar?
      # return false unless meet_personal_interest_criteria?
      # return false unless metacritic.to_i >= 70

      # == UNPROCESSED ==
      # return false unless meet_minimum_quality_bar?
      # return false if processed?
      # return false unless must_see? || certified_fresh?

      true
    end

    private

    def meet_minimum_quality_bar?
      return false unless rated?
      return false unless box_office.to_i >= 20
      return false unless certified_fresh?

      true
    end

    def meet_personal_interest_criteria?
      return false if animation? || documentary? || horror? || musical? || juvenile?
      return false unless display_year.to_i >= 2000

      true
    end
  end
end
