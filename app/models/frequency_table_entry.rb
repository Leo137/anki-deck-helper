class FrequencyTableEntry < ApplicationRecord
  validates :content, presence: true, uniqueness: { scope: :frequency_table_id }

  belongs_to :frequency_table
end
