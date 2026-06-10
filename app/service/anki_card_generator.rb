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

  private

  def generate_front
    "<h1>#{content}</h1>"
  end

  def generate_back
    return 'No data available. Sorry :(' unless entries.any?

    entries.map do |entry|
      entry.to_s(dictionary:).gsub(/(?:\n\r?|\r\n?)/, '<br>')
    end.join('<br>')
  end

  def entries
    @entries ||= (
        Dictionary::Entry.where(text: content) +
        Dictionary::Reading.where(text: content).map(&:dictionary_entry)
      ).flatten.compact.uniq
       .select { |entry| entry.meanings.any? { |m| m.dictionary_id == dictionary.id } }
       .sort_by(&:jmdict_id)
  end
end
