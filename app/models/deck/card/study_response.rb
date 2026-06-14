# frozen_string_literal: true

class Deck
  class Card
    class StudyResponse < ApplicationRecord
      self.table_name = 'deck_card_study_responses'

      belongs_to :user
      belongs_to :deck_card, class_name: 'Deck::Card', inverse_of: :study_responses

      validates :correct, inclusion: { in: [true, false] }
      validate :deck_card_belongs_to_user_deck

      scope :for_user, ->(user) { where(user:) }

      def self.stats_for(user:, card:)
        responses = for_user(user).where(deck_card: card)
        know_count = responses.where(correct: true).count
        dont_know_count = responses.where(correct: false).count
        total = know_count + dont_know_count
        last = responses.order(created_at: :desc).first

        {
          know_count:,
          dont_know_count:,
          total_responses: total,
          accuracy_rate: total.positive? ? (know_count.to_f / total).round(3) : nil,
          last_responded_at: last&.created_at,
          last_correct: last&.correct
        }
      end

      private

      def deck_card_belongs_to_user_deck
        return if deck_card.nil? || user.nil?
        return if deck_card.deck.user_id == user.id

        errors.add(:deck_card, 'must belong to one of the user decks')
      end
    end
  end
end
