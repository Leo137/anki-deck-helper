# frozen_string_literal: true

# Creates javascript deck based on a list of words
# Creates a Javascript deck (JS format code) based on a list of words
class JavascriptDeckGenerator
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
    # Write data to File containing array

    File.open(file_path, "w") do |file|
    	file.puts "const words = ["

      cards.each do |card|
        file.puts card.to_json + ','
      end

      file.puts "];"
    end
  end

  def file_path
    "decks/javascript_#{deck_name}.js"
  end

  def cards
    @cards ||= generate_cards
  end

  def generate_cards
    words.map(&:to_javascript_card).compact
  end
end
