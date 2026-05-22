# frozen_string_literal: true

module Services
  class MovieFilter < SimpleDelegator
    def self.keep?(item) = new(item).keep?

    def keep?
      # == KIDS ==
      return false unless meet_minimum_quality_bar?
      return false unless meet_personal_interest_criteria?
      # return false unless box_office.to_i >= 50
      # return false if !restricted?
      return false unless rated?

      # == FOREIGN ==
      # return false unless foreign?
      # return false unless popularity.to_i >= 1
      # return false unless metacritic.to_i >= 70
      # return false unless rotten_tomatoes.to_i >= 75
      # return false unless box_office.to_i >= 1

      # == DATE NIGHT ==
      # return false unless meet_minimum_quality_bar?
      # return false unless meet_personal_interest_criteria?
      # return false unless metacritic.to_i >= 70

      # == UNPROCESSED ==
      return false unless box_office.to_i >= 1
      # return false if processed?
      # return false unless must_see? || certified_fresh?

      true
    end

    private

    def meet_minimum_quality_bar?
      # return false unless box_office.to_i.between?(10, 19)
      return false unless certified_fresh?

      true
    end

    def meet_personal_interest_criteria?
      return false if animation? || musical? || juvenile? #|| !foreign?
      # return false unless display_year.to_i >= 2000

      true
    end
  end
end
