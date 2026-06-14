# frozen_string_literal: true

class DeckCreationJob < ApplicationJob
  queue_as :default

  around_perform :log_execution

  def perform(deck_id, word_set_ids:, frequency_table_ids:)
    deck = Deck.find_by(id: deck_id)
    return unless deck

    DeckGenerator.new(
      deck:,
      word_set_ids:,
      frequency_table_ids:
    ).call
  end

  private

  def log_execution
    deck_id = arguments.first
    log_job_started(deck_id)

    yield

    log_job_finished(deck_id)
  rescue StandardError => e
    DeckCreationLogger.exception('DeckCreationJob failed', e, job_id:, deck_id:)
    raise
  end

  def log_job_started(deck_id)
    job_params = arguments.second || {}
    DeckCreationLogger.info(
      'DeckCreationJob started',
      job_id:,
      deck_id:,
      word_set_ids: job_params[:word_set_ids] || job_params['word_set_ids'],
      frequency_table_ids: job_params[:frequency_table_ids] || job_params['frequency_table_ids']
    )
  end

  def log_job_finished(deck_id)
    deck = Deck.find_by(id: deck_id)
    return unless deck

    DeckCreationLogger.info(
      'DeckCreationJob finished',
      job_id:,
      deck_id:,
      deck_status: deck.status
    )
  end
end
