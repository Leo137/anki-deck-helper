# frozen_string_literal: true

namespace :dictionary do
  desc 'Assign existing Dictionary::Meaning records to the English JMDict dictionary'
  task assign_english_dictionary: :environment do
    language = Language.find_or_create_by_code!(:en)
    dictionary = Dictionary.find_or_create_for!(name: 'jmdict-eng-3.5.0', language:)

    updated = Dictionary::Meaning.where(dictionary_id: nil).update_all(dictionary_id: dictionary.id)

    puts "Assigned #{updated} meanings to #{dictionary.name} (#{language.code})"
  end
end
