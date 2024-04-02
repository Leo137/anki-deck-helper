# frozen_string_literal: true

# Creates anki card from a word record
class AnkiCardGenerator
  attr_accessor :word

  delegate :content, to: :word

  def initialize(word)
    @word = word
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
      entry.to_s.gsub(/(?:\n\r?|\r\n?)/, '<br>')
    end.join('<br>')
  end

  def entries
    @entries ||= (
        Dictionary::Entry.where(text: content) +
        Dictionary::Reading.where(text: content).map(&:dictionary_entry)
      ).flatten.compact.uniq.sort_by(&:jmdict_id)
  end
end
