# frozen_string_literal: true

class Deck
  class Study
    class CardPicker
      RECENT_FAILURE_WINDOW = 24.hours
      BASE_WEIGHT = 1.0
      NEW_CARD_BOOST = 1.0
      LOW_ACCURACY_MULTIPLIER = 2.0
      RECENT_FAILURE_BOOST = 3.0

      def initialize(deck:, user:, exclude_card_id: nil)
        @deck = deck
        @user = user
        @exclude_card_id = exclude_card_id&.to_i
      end

      def pick
        cards = @deck.cards.includes(:fields).order(:position).to_a
        return nil if cards.empty?

        pool = cards.reject { |card| card.id == @exclude_card_id }
        pool = cards if pool.empty?

        weights = pool.map { |card| [card, weight_for(card)] }
        weighted_random(weights)
      end

      private

      def weight_for(card)
        stats = stats_by_card_id[card.id] || empty_stats
        weight = BASE_WEIGHT

        if stats[:total].zero?
          weight += NEW_CARD_BOOST
        else
          accuracy = stats[:know_count].to_f / stats[:total]
          weight += (1 - accuracy) * LOW_ACCURACY_MULTIPLIER
        end

        if stats[:last_correct] == false && stats[:last_at]&.>(RECENT_FAILURE_WINDOW.ago)
          weight += RECENT_FAILURE_BOOST
        end

        weight
      end

      def stats_by_card_id
        @stats_by_card_id ||= begin
          card_ids = @deck.cards.pluck(:id)
          return {} if card_ids.empty?

          aggregates = Deck::Card::StudyResponse
                       .where(user: @user, deck_card_id: card_ids)
                       .group(:deck_card_id)
                       .pluck(
                         :deck_card_id,
                         Arel.sql('SUM(CASE WHEN correct THEN 1 ELSE 0 END)'),
                         Arel.sql('SUM(CASE WHEN NOT correct THEN 1 ELSE 0 END)')
                       )

          last_by_card = Deck::Card::StudyResponse
                         .where(user: @user, deck_card_id: card_ids)
                         .select('DISTINCT ON (deck_card_id) deck_card_id, correct, created_at')
                         .order(:deck_card_id, created_at: :desc)
                         .index_by(&:deck_card_id)

          aggregates.each_with_object({}) do |(card_id, know_count, dont_know_count), hash|
            total = know_count + dont_know_count
            last = last_by_card[card_id]
            hash[card_id] = {
              know_count:,
              dont_know_count:,
              total:,
              last_correct: last&.correct,
              last_at: last&.created_at
            }
          end
        end
      end

      def empty_stats
        { know_count: 0, dont_know_count: 0, total: 0, last_correct: nil, last_at: nil }
      end

      def weighted_random(weights)
        total = weights.sum(&:last)
        target = rand * total
        cumulative = 0.0

        weights.each do |card, weight|
          cumulative += weight
          return card if cumulative >= target
        end

        weights.last.first
      end
    end
  end
end
