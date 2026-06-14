# frozen_string_literal: true

FactoryBot.define do
  factory :deck_card_field, class: 'Deck::Card::Field' do
    card factory: %i[deck_card]
    side { :front }
    html_content { '<h1>example</h1>' }

    trait :front do
      side { :front }
      html_content { '<h1>ふもと</h1>' }
    end

    trait :back do
      side { :back }
      html_content do
        '<div class="reading">ふもと</div><br><hr><div class="tags">uk-n</div><br>' \
          '<div class="definition">* foot (of a mountain or hill)</div><br>' \
          '<div class="definition">* bottom</div><br><div class="definition">* base</div><br><br>'
      end
    end
  end
end
