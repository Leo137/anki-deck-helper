# frozen_string_literal: true

class Deck
  class Destroyer
    attr_reader :deck

    def initialize(deck:)
      @deck = deck
    end

    def call
      cancel_creation_jobs!
      deck.destroy!
    end

    private

    def cancel_creation_jobs!
      creation_jobs.each do |job|
        job.discard_job('Deck deleted')
      end
    end

    def creation_jobs
      GoodJob::Job
        .where(finished_at: nil, job_class: 'DeckCreationJob')
        .select { |job| job.serialized_params.dig('arguments', 0) == deck.id }
    end
  end
end
