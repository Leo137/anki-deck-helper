# frozen_string_literal: true

# Creates kotoba card array[string] from a word record
class KotobaCardGenerator
  attr_accessor :word

  delegate :content, to: :word

  def initialize(word)
    @word = word
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
    end.flatten.compact.uniq.join(',')
  end

  def comment
    entries.map do |entry|
      entry.meanings.map do |meaning|
        meaning.definitions.map(&:text)
      end.flatten.compact.uniq
    end.flatten.compact.uniq.join(',')
  end

  def instructions
    'Type the reading!'
  end

  def render_as
    'Image'
  end

  def entries
    @entries ||= (
        Dictionary::Entry.where(text: content) +
        Dictionary::Reading.where(text: content).map(&:dictionary_entry)
      ).flatten.compact.uniq.sort_by(&:jmdict_id)
  end
end
