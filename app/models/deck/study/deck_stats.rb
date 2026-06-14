# frozen_string_literal: true

class Deck
  class Study
    class DeckStats
      def initialize(deck:, user:)
        @deck = deck
        @user = user
      end

      def summary
        card_ids = @deck.cards.pluck(:id)
        return empty_summary if card_ids.empty?

        responses_by_card = Deck::Card::StudyResponse
                            .where(user: @user, deck_card_id: card_ids)
                            .order(:created_at)
                            .group_by(&:deck_card_id)

        counts = { young: 0, learning: 0, mature: 0 }
        responses_by_card.each_value do |responses|
          factor = Maturity.factor_for(responses)
          counts[Maturity.stage_for(factor)] += 1
        end

        {
          not_reviewed_count: card_ids.size - responses_by_card.size,
          young_count: counts[:young],
          learning_count: counts[:learning],
          mature_count: counts[:mature]
        }
      end

      private

      def empty_summary
        {
          not_reviewed_count: 0,
          young_count: 0,
          learning_count: 0,
          mature_count: 0
        }
      end
    end
  end
end
