# frozen_string_literal: true

# Creates anki card from a word record
class AnkiCardGenerator
  attr_accessor :word, :dictionary

  delegate :content, to: :word

  def initialize(word, dictionary:)
    @word = word
    @dictionary = dictionary
  end

  def call
    {
      front: generate_front,
      back: generate_back
    }
  end

  def generate_front
    "<h1>#{content}</h1>"
  end

  def generate_back
    return 'No data available. Sorry :(' unless entries.any?

    entries.map do |entry|
      entry.to_s(dictionary:).gsub(/(?:\n\r?|\r\n?)/, '<br>')
    end.join('<br>')
  end

  private

  def entries
    @entries ||= matched_entries.select { |entry| entry_in_dictionary?(entry) }
  end

  def matched_entries
    (
      Dictionary::Entry.where(text: content) +
      Dictionary::Reading.where(text: content).map(&:dictionary_entry)
    ).flatten.compact.uniq.sort_by { |entry| [entry.jmdict_id.nil? ? 1 : 0, entry.jmdict_id.to_i] }
  end

  def entry_in_dictionary?(entry)
    entry.meanings.any? { |meaning| meaning.dictionary_id == dictionary.id }
  end
end
