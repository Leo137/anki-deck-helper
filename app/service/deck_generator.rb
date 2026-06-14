# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class DeckGenerator
  class Error < StandardError; end

  attr_reader :deck, :word_set_ids, :frequency_table_ids

  def initialize(deck:, word_set_ids:, frequency_table_ids:)
    @deck = deck
    @word_set_ids = word_set_ids.map(&:to_i)
    @frequency_table_ids = frequency_table_ids.map(&:to_i)
  end

  def call
    run_generation
  rescue Error => e
    mark_deck_failed!(e.message)
  rescue StandardError => e
    handle_unexpected_error(e)
  end

  private

  def run_generation
    log_generation_started
    return unless deck_exists?

    dictionary = prepare_deck_for_generation!
    generate_cards!(collect_and_rank_words, dictionary:)
    mark_deck_ready! if deck_exists?
  end

  def handle_unexpected_error(error)
    deck.cards.destroy_all if deck_exists?
    DeckCreationLogger.exception('Deck generation error', error, deck_id: deck.id)
    mark_deck_failed!(error.message)
    raise
  end

  def deck_exists?
    Deck.exists?(deck.id)
  end

  def collect_and_rank_words
    rank_words(collect_words)
  end

  def collect_words
    words = words_scope
    raise Error, 'No words found for the selected word sets' if words.none?

    DeckCreationLogger.info('Words collected', deck_id: deck.id, word_count: words.count)
    words
  end

  def rank_words(words)
    frequency_tables = FrequencyTable.where(id: frequency_table_ids)
    ranked_words = WordPriorityEstimator.new(words, frequency_tables).call
    DeckCreationLogger.info(
      'Word priority estimated',
      deck_id: deck.id,
      ranked_word_count: ranked_words.size,
      frequency_table_names: frequency_tables.pluck(:name).join(',')
    )
    ranked_words
  end

  def log_generation_started
    DeckCreationLogger.info(
      'Deck generation started',
      deck_id: deck.id,
      user_id: deck.user_id,
      deck_name: deck.name,
      word_set_ids:,
      frequency_table_ids:
    )
  end

  def prepare_deck_for_generation!
    deck.processing!
    dictionary = dictionary_for_user
    DeckCreationLogger.info(
      'Dictionary resolved',
      deck_id: deck.id,
      dictionary_id: dictionary.id,
      dictionary_name: dictionary.name,
      language: deck.user.preferred_language
    )
    dictionary
  end

  def generate_cards!(ranked_words, dictionary:)
    deck.cards.destroy_all
    total = ranked_words.size
    update_generation_progress!(0, total:)

    ranked_words.each_with_index do |word_object, index|
      next unless deck_exists?

      create_card_for!(word_object.word, dictionary:, position: index + 1)
      update_generation_progress!(index + 1, total:)
    end
  end

  def update_generation_progress!(completed, total:)
    return unless deck_exists?

    progress = total.positive? ? ((completed.to_f / total) * 100).round : 0
    return if deck.generation_progress == progress && deck.generation_total == total

    deck.update_columns(
      generation_progress: progress,
      generation_total: total,
      updated_at: Time.current
    )
  end

  def mark_deck_ready!
    return unless deck_exists?

    deck.update_columns(
      status: Deck.statuses[:ready],
      error_message: nil,
      generation_progress: 100,
      updated_at: Time.current
    )
    DeckCreationLogger.info('Deck generation completed', deck_id: deck.id, cards_count: deck.cards.count)
  end

  def mark_deck_failed!(message)
    return unless deck_exists?

    deck.update_columns(status: Deck.statuses[:failed], error_message: message, updated_at: Time.current)
    DeckCreationLogger.error('Deck generation failed', deck_id: deck.id, message:)
  end

  def dictionary_for_user
    Dictionary.joins(:language)
              .where(languages: { code: deck.user.preferred_language })
              .order(:id)
              .first!
  rescue ActiveRecord::RecordNotFound
    raise Error, "No dictionary available for language #{deck.user.preferred_language}"
  end

  def words_scope
    Word.joins(:word_sets)
        .where(word_sets: { id: word_set_ids })
        .distinct
  end

  def create_card_for!(word, dictionary:, position:)
    generator = AnkiCardGenerator.new(word, dictionary:)
    card = build_card(generator, position:)
    card.save!
  rescue StandardError => e
    log_card_creation_failure(e, word:, position:)
    raise
  end

  def build_card(generator, position:)
    card = Deck::Card.new(deck:, position:)
    card.fields.build(side: :front, html_content: html_content_for(generator.generate_front))
    card.fields.build(side: :back, html_content: html_content_for(generator.generate_back))
    card
  end

  def log_card_creation_failure(error, word:, position:)
    DeckCreationLogger.exception(
      'Card creation failed',
      error,
      deck_id: deck.id,
      position:,
      word_id: word.id,
      word_content: word.content
    )
  end

  def html_content_for(content)
    content.presence || '<p>No content available.</p>'
  end
end
# rubocop:enable Metrics/ClassLength
