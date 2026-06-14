# frozen_string_literal: true

class Deck
  class Creator
    class Error < StandardError; end

    attr_reader :user, :name, :word_set_ids, :frequency_table_ids

    def initialize(user:, name:, word_set_ids:, frequency_table_ids:)
      @user = user
      @name = name.to_s.strip
      @word_set_ids = Array(word_set_ids).map(&:to_i).uniq
      @frequency_table_ids = Array(frequency_table_ids).map(&:to_i).uniq
    end

    def call
      validate!

      deck = user.decks.create!(name:, status: :pending)
      DeckCreationJob.perform_later(deck.id, word_set_ids:, frequency_table_ids:)
      deck
    end

    private

    def validate!
      raise Error, 'Name is required' if name.blank?
      raise Error, 'Select at least one word set' if word_set_ids.empty?
      raise Error, 'Select at least one frequency table' if frequency_table_ids.empty?
      raise Error, 'One or more word sets were not found' unless word_sets_exist?
      raise Error, 'One or more frequency tables were not found' unless frequency_tables_exist?
    end

    def word_sets_exist?
      WordSet.where(id: word_set_ids).count == word_set_ids.size
    end

    def frequency_tables_exist?
      FrequencyTable.where(id: frequency_table_ids).count == frequency_table_ids.size
    end
  end
end
