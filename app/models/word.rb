class Word < ApplicationRecord
  validates :content, presence: true, uniqueness: true

  has_and_belongs_to_many :word_sets
  has_many :word_frequencies, dependent: :destroy
  has_many :word_tags, dependent: :destroy
  has_many :frequency_tables, through: :word_frequencies
  has_many :tags, through: :word_tags

  scope :frequency_ordered, -> { includes(:word_frequencies).order('word_frequencies.frequency') }

  def self.by_frequency_table(frequency_table)
    includes(:word_frequencies)
      .where(word_frequencies: { frequency_table: })
  end

  def self.by_word_sets(word_sets)
    includes(:word_sets)
      .where(word_sets: { id: word_sets.pluck(:id) })
  end

  def tag!
    if content[/^~/]
      # Word is a counter
      word_tags.build(tag: Tag.find_or_create_by(name: 'counter'))
      content.gsub!('~', '')
    end
  end

  def self.sorted_words_by_frequency_table(name)
    joins(word_frequencies: :frequency_table)
      .where(frequency_table: { name: })
      .order('word_frequencies.frequency ASC')
  end
end
