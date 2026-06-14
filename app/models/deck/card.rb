# frozen_string_literal: true

class Deck
  class Card < ApplicationRecord
    self.table_name = 'deck_cards'

    belongs_to :deck, inverse_of: :cards
    has_many :fields, class_name: 'Deck::Card::Field', foreign_key: 'deck_card_id', dependent: :destroy,
                      inverse_of: :card

    validates :position, presence: true, uniqueness: { scope: :deck_id }
    validate :must_have_front_and_back_fields

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
