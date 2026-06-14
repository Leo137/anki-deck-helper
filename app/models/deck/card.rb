# frozen_string_literal: true

class Deck
  class Card < ApplicationRecord
    self.table_name = 'deck_cards'

    belongs_to :deck, inverse_of: :cards
    has_many :fields, class_name: 'Deck::Card::Field', foreign_key: 'deck_card_id', dependent: :destroy,
                      inverse_of: :card
    has_many :study_responses, class_name: 'Deck::Card::StudyResponse', foreign_key: 'deck_card_id',
                               dependent: :destroy, inverse_of: :deck_card

    validates :position, presence: true, uniqueness: { scope: :deck_id }
    validate :must_have_front_and_back_fields

    scope :search_by_front_content, lambda { |query|
      normalized = query.to_s.strip
      next all if normalized.blank?

      pattern = "%#{sanitize_sql_like(normalized)}%"
      matching_card_ids = Deck::Card::Field.front.where('html_content ILIKE ?', pattern).select(:deck_card_id)
      where(id: matching_card_ids)
    }

    def front_field
      fields.find(&:front?)
    end

    def back_field
      fields.find(&:back?)
    end

    def front_preview
      html = front_field&.html_content
      return '' if html.blank?

      ActionController::Base.helpers.strip_tags(html).squish.truncate(120)
    end

    private

    def must_have_front_and_back_fields
      sides = fields.map(&:side)
      return if sides.include?('front') && sides.include?('back')

      errors.add(:fields, 'must include front and back')
    end
  end
end
