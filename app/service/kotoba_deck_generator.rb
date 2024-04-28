# frozen_string_literal: true

# Creates kotoba deck CSV based on a list of words
# frozen_string_literal: true

require 'csv'

# Creates a kotoba deck (CSV format) based on a list of words
class KotobaDeckGenerator
  attr_accessor :words, :deck_name

  def initialize(words, deck_name)
    @words = words
    @deck_name = deck_name
  end

  def call
    generate_deck
  end

  private

  def generate_deck
    # Write data to CSV
    CSV.open(file_path, 'wb') do |csv|
      cards.each do |card|
        csv << card
      end
    end
  end

  def file_path
    "decks/kotoba_#{deck_name}.csv"
  end

  def cards
    @cards ||= generate_cards
  end

  def generate_cards
    words.map(&:to_kotoba_card).compact
  end
end
