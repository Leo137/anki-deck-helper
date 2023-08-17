class Dictionary::Entry < ApplicationRecord
  has_many :meanings, class_name: 'Dictionary::Meaning', foreign_key: 'dictionary_entry_id', dependent: :destroy
  has_many :readings, class_name: 'Dictionary::Reading', foreign_key: 'dictionary_entry_id', dependent: :destroy

  validates :text, presence: true

  def to_s
    <<~TEXT
      #{readings.where(is_kana: true).map { |d| "<div class='reading'>#{d.text}</div>" }.join("\n")}
      <hr>#{meanings.map(&:to_s).join("\n")}
    TEXT
  end
end
