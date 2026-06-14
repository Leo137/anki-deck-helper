# frozen_string_literal: true

FactoryBot.define do
  factory :deck_card, class: 'Deck::Card' do
    deck
    sequence(:position) { |n| n }

    trait :complete do
      after(:build) do |card|
        card.fields.build(side: :front, html_content: '<h1>ふもと</h1>') unless card.fields.any?(&:front?)
        unless card.fields.any?(&:back?)
          card.fields.build(
            side: :back,
            html_content: '<div class="reading">ふもと</div><br><hr><div class="tags">uk-n</div><br>' \
                          '<div class="definition">* foot (of a mountain or hill)</div><br>' \
                          '<div class="definition">* bottom</div><br><div class="definition">* base</div><br><br>'
          )
        end
      end
    end
  end
end
