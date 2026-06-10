# frozen_string_literal: true

class Dictionary::Meaning < ApplicationRecord
  self.table_name = 'dictionary_meanings'

  belongs_to :dictionary_entry, class_name: 'Dictionary::Entry', foreign_key: 'dictionary_entry_id'
  belongs_to :dictionary

  has_many :definitions, foreign_key: 'dictionary_meaning_id', dependent: :destroy
  has_many :fields, foreign_key: 'dictionary_meaning_id', dependent: :destroy
  has_many :misc_tags, foreign_key: 'dictionary_meaning_id', dependent: :destroy
  has_many :part_of_speeches, foreign_key: 'dictionary_meaning_id', dependent: :destroy

  def cloud_tag
    misc_tags.map(&:code) + fields.map(&:code) + part_of_speeches.map(&:code)
  end

  def cloud_tag_label
    cloud_tag.join('-').presence
  end

  def to_s
    result = ''
    result += "<div class='tags'>#{cloud_tag_label}</div><br>" if cloud_tag_label
    result += definitions.map { |d| "<div class='definition'>* #{d.text}</div>" }.join("\n")
    result += "\n"
    result
  end
end
