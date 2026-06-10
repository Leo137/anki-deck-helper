# frozen_string_literal: true

# Creates kotoba card array[string] from a word record
class KotobaCardGenerator
  attr_accessor :word, :dictionary

  delegate :content, to: :word

  def initialize(word, dictionary:)
    @word = word
    @dictionary = dictionary
  end

  def call
    return nil unless answers.present? && comment.present?

    [
      question,
      answers,
      comment,
      instructions,
      render_as
    ]
  end

  private

  def question
    content
  end

  def answers
    entries.map do |entry|
      entry.readings.where(is_kana: true).map(&:text)
    end.flatten.compact.uniq.join(',')[0, 600]
  end

  def comment
    entries.map do |entry|
      entry.meanings_for(dictionary:).map do |meaning|
        meaning.definitions.map(&:text)
      end.flatten.compact.uniq
    end.flatten.compact.uniq.join(',').truncate(590)
  end

  def instructions
    'Type the reading!'
  end

  def render_as
    'Image'
  end

  def entries
    @entries ||= matched_entries.select { |entry| entry_in_dictionary?(entry) }
  end

  def matched_entries
    (
      Dictionary::Entry.where(text: content) +
      Dictionary::Reading.where(text: content).map(&:dictionary_entry)
    ).flatten.compact.uniq.sort_by(&:jmdict_id)
  end

  def entry_in_dictionary?(entry)
    entry.meanings.any? { |meaning| meaning.dictionary_id == dictionary.id }
  end
end
