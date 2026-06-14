# frozen_string_literal: true

class CreateDeckCardStudyResponses < ActiveRecord::Migration[7.0]
  def change
    create_table :deck_card_study_responses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :deck_card, null: false, foreign_key: true
      t.boolean :correct, null: false

      t.timestamps
    end

    add_index :deck_card_study_responses, %i[user_id deck_card_id]
    add_index :deck_card_study_responses, %i[user_id deck_card_id created_at],
              name: 'index_deck_card_study_responses_on_user_card_created_at'
  end
end
