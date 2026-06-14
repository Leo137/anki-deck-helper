# frozen_string_literal: true

class Deck
  class Study
    class Maturity
      CORRECT_INCREMENT = 0.3
      MAX_FACTOR = 5.0

      def self.factor_for(responses)
        responses.sort_by(&:created_at).reduce(0.0) do |factor, response|
          if response.correct
            [factor + CORRECT_INCREMENT, MAX_FACTOR].min
          else
            factor / 2.0
          end
        end
      end

      def self.stage_for(factor)
        return :young if factor <= 1.0
        return :learning if factor <= 2.0

        :mature
      end
    end
  end
end
