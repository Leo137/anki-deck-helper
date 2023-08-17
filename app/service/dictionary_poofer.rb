# frozen_string_literal: true

# Poofs the dictionary. *poof*
class DictionaryPoofer
  def call
    Dictionary::Meaning::Definition.delete_all
    Dictionary::Meaning::Field.delete_all
    Dictionary::Meaning::MiscTag.delete_all
    Dictionary::Meaning::PartOfSpeech.delete_all
    Dictionary::Meaning.delete_all
    Dictionary::Reading.delete_all
    Dictionary::Entry.delete_all
  end
end
