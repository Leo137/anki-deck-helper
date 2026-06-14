# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeckCreationLogger do
  around do |example|
    described_class.reset!
    FileUtils.rm_f(described_class::LOG_PATH)
    example.run
  ensure
    described_class.reset!
    FileUtils.rm_f(described_class::LOG_PATH)
  end

  it 'writes structured messages to log/deck_creation.log' do
    described_class.info('Deck generation started', deck_id: 42, word_count: 10)

    log = File.read(described_class::LOG_PATH)
    expect(log).to include('INFO -- Deck generation started')
    expect(log).to include('deck_id=42')
    expect(log).to include('word_count=10')
  end

  it 'logs exceptions with backtrace lines' do
    error = StandardError.new('something broke')
    error.set_backtrace(['line 1', 'line 2'])

    described_class.exception('Deck generation error', error, deck_id: 7)

    log = File.read(described_class::LOG_PATH)
    expect(log).to include('Deck generation error: StandardError: something broke')
    expect(log).to include('line 1')
  end
end
