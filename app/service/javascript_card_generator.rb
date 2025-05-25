# frozen_string_literal: true

# Creates simple dictionary entry from a word record, to
# be used in a mini SRS web application
class JavascriptCardGenerator
  attr_accessor :word

  delegate :content, to: :word

  def initialize(word)
    @word = word
  end

  def call
    return nil unless kanji.present? && meaning.present?

    {
    	kanji: kanji,
    	kana: kana,
    	meaning: meaning
    }
  end

  private

  def kanji
  	content
  end

  def kana
    entries.map do |entry|
      entry.readings.where(is_kana: true).map(&:text)
    end.flatten.compact.uniq.join(', ')
  end

  def meaning
    entries.map do |entry|
      entry.meanings.map do |meaning|
        meaning.definitions.map(&:text)
      end.flatten.compact.uniq
    end.flatten.compact.uniq.join(', ')
  end

  def entries
    @entries ||= (
        Dictionary::Entry.where(text: content).to_a
      ).flatten.compact.uniq.sort_by(&:jmdict_id)
  end
end
