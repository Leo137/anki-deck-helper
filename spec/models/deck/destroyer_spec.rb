# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Deck::Destroyer do
  let(:user) { create(:user) }
  let(:deck) { create(:deck, user:, status: :pending) }
  let(:job) { instance_double(GoodJob::Job) }

  it 'destroys the deck and its cards' do
    create(:deck_card, :complete, deck:, position: 1)

    expect do
      described_class.new(deck:).call
    end.to change(Deck, :count).by(-1)
                               .and change(Deck::Card, :count).by(-1)
  end

  it 'discards unfinished creation jobs for the deck' do
    jobs_scope = instance_double(ActiveRecord::Relation)
    allow(GoodJob::Job).to receive(:where)
      .with(finished_at: nil, job_class: 'DeckCreationJob')
      .and_return(jobs_scope)
    allow(jobs_scope).to receive(:select).and_return([job])
    expect(job).to receive(:discard_job).with('Deck deleted')

    described_class.new(deck:).call
  end
end
